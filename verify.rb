require 'yaml'
require 'fastimage'
require 'kwalify'
@output = 0

# YAML tags related to TFA
@tfa_tags = { true => [*@tfa_forms, 'doc'],
              false => %w(status twitter facebook email_address lang) }

# TFA forms
@tfa_forms = %w(email hardware software sms phone)

# Image max size (in bytes)
@img_max_size = 2500

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '.png'

## validator class for websites
class WebsitesValidator < Kwalify::Validator

   ## load schema definition
  @@schema = Kwalify::Yaml.load_file('websites_schema.yml')

  def initialize()
    super(@@schema)
  end

  ## hook method called by Validator#validate()
  def validate_hook(value, rule, path, errors)
    case rule.name
    when 'Website'
      @tfa_tags[value['tfa']].each do |tag|
        next if value[tag].nil?
        errors << Kwalify::ValidationError.new("\'#{tag}\' should NOT be "\
            "present when tfa: #{value['tfa'] ? 'true' : 'false'}.", path)
      end
    end
  end
end

# Send error message
def error(msg)
  @output += 1
  puts "<------------ ERROR ------------>\n" if @output == 1
  puts "#{@output}. #{msg}"
end

# rubocop:disable AbcSize,CyclomaticComplexity
def test_img(img, name, imgs)
  # Exception if image file not found
  raise "#{name} image not found." unless File.exist?(img)
  # Remove img from array unless it doesn't exist (double reference case)
  imgs.delete_at(imgs.index(img)) unless imgs.index(img).nil?

  # Check image dimensions
  error("#{img} is not #{@img_dimensions.join('x')} pixels.")\
    unless FastImage.size(img) == @img_dimensions

  # Check image file extension and type
  error("#{img} is not using the #{@img_extension} format.")\
    unless File.extname(img) == @img_extension && FastImage.type(img) == :png

  # Check image file size
  img_size = File.size(img)
  return unless img_size > @img_max_size
  error("#{img} should not be larger than #{@img_max_size} bytes. It is"\
          " currently #{img_size} bytes.")
end
# rubocop:enable AbcSize,CyclomaticComplexity

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  sections = YAML.load_file('_data/sections.yml')
  schema = YAML.load_file('websites_schema.yml')
  validator = Kwalify::Validator.new(schema)
  sections.each do |section|
    data = YAML.load_file('_data/' + section['id'] + '.yml')
    websites = data['websites']
    errors = validator.validate(data)

    if errors && !errors.empty?
      errors.each do |e|
        index = e.path.split('/').last.to_i
        error("#{websites.at(index)['name']}: #{e.message}")
      end
    end

    # Check section alphabetization
    error("_data/#{section['id']}.yml is not alphabetized by name") \
      if websites != websites.sort_by { |website| website['name'].downcase }

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each do |website|
      @tfa_tags[!website['tfa']].each do |tag|
        next if website[tag].nil?
        error("#{website['name']}: The YAML tag \'#{tag}\' should NOT be "\
              "present when TFA is #{website['tfa'] ? 'enabled' : 'disabled'}.")
      end
      test_img("img/#{section['id']}/#{website['img']}", website['name'],
               imgs)
    end

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
