require 'yaml'
require 'fastimage'
require 'kwalify'
@output = 0

# YAML tags related to TFA
@tfa_tags = {
  # YAML tags for TFA Yes
  true => %w[email hardware software sms phone doc],
  # YAML tags for TFA No
  false => %w[status twitter facebook email_address lang]
}.freeze

# Website Kwalify Validator
class WebsiteValidator < Kwalify::Validator
  # Image max size (in bytes)
  @img_max_size = 2500
  # Image dimensions
  @img_dimensions = [32, 32].freeze
  # Image format used for all images
  @img_extension = '.png'.freeze

  def initialize(tfa_tags)
    @tfa_tags = tfa_tags
    super(Kwalify::Yaml.load_file('websites_schema.yml'))
  end

  def self.add_error(msg)
    @errors << Kwalify::ValidationError.new(msg, @path)
  end

  def self.validate_img(value)
    # Check image dimensions
    add_error("#{value} is not #{@img_dimensions.join('x')} pixels.") \
      unless FastImage.size(value) == @img_dimensions
    # Check image file extension and type
    add_error("#{value} is not using the #{@img_extension} format.") \
      unless File.extname(value) == @img_extension && \
             FastImage.type(value) == :png
    # Check image file size
    add_error("#{value} should not be larger than #{@img_max_size} bytes.") \
      unless File.size(value) > @img_max_size
  end

  def check_tags(value)
    case value
    when 'tfa'
      tag = false
      @tfa_tags[true].each { |true_tag| tag = true unless true_tag.empty? }
      add_error("one of #{@tfa_tags[true]} is required") unless tag
    when 'img'
      # Exception if image file not found
      raise "#{name} image not found." unless File.exist?(img)
      validate_img(value)
    else
      add_error("\'#{value}\' should NOT be " \
        "present when tfa: #{value['tfa'] ? 'true' : 'false'}.") \
        unless @tfa_tags[!value['tfa']][value].nil?
    end
  end

  ## hook method called by Validator#validate()
  def validate_hook(value, rule, path, errors)
    @path = path
    @errors = errors
    case rule.name
    when 'Website'
      check_tags(value)
    end
  end
end

# Send error message
def error(msg)
  @output += 1
  puts "<------------ ERROR ------------>\n" if @output == 1
  puts "#{@output}. #{msg}"
end

def test_img(img, imgs)
  # Remove img from array unless it doesn't exist (double reference case)
  imgs.delete_at(imgs.index(img)) unless imgs.index(img).nil?
end

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  sections = YAML.load_file('_data/sections.yml')
  # Check sections.yml alphabetization
  error('section.yml is not alphabetized by name') \
    if sections != (sections.sort_by { |section| section['id'].downcase })
  validator = WebsiteValidator.new(@tfa_tags)
  sections.each do |section|
    data = YAML.load_file("_data/#{section['id']}.yml")
    websites = data['websites']
    errors = validator.validate(data)

    errors.each do |e|
      error("#{websites.at(e.path.split('/')[2].to_i)['name']}: #{e.message}")
    end

    # Check section alphabetization
    error("_data/#{section['id']}.yml is not alphabetized by name") \
      if websites != (websites.sort_by { |website| website['name'].downcase })

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each { |website| test_img("img/#{section['id']}/#{website['img']}", imgs) }

    # After removing images associated with entries in test_img, alert
    # for unused or orphaned images
    imgs.each { |img| next unless img.nil? error("#{img} is not used") }
  end

  exit 1 if @output > 0
rescue Psych::SyntaxError => e
  puts "<------------ ERROR in a YAML file ------------>\n"
  puts e
  exit 1
rescue => e
  puts e
  exit 1
else
  puts "<------------ No errors. You\'re good to go! ------------>\n"
end
