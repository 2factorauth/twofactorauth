require 'yaml'
require 'fastimage'
require 'kwalify'
require 'diffy'
@output = 0
@allowed_output = 0
@total_tracked = 0
@total_support = 0

# Image max size (in bytes)
@img_recommended_size = 2500

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '.png'

# Send error message
def error(msg)
  @output += 1
  puts "  #{@output}. #{msg}"
end

# rubocop:disable AbcSize
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
  test_img_size(img)
end

def test_img_size(img)
  file_size = File.size(img)
  return unless file_size > @img_recommended_size

  error("#{img} should not be larger than #{@img_recommended_size} bytes. "\
          "It is currently #{file_size} bytes.")

  @allowed_output += 1
end

# rubocop:disable MethodLength
def process_section(section, validator)
  section_file = "_data/#{section['id']}.yml"
  data = YAML.load_file(File.join(__dir__, section_file))
  websites = data['websites']
  errors = validator.validate(data)

  errors.each do |e|
    error("#{section_file}:#{websites.at(e.path.split('/')[2].to_i)['name']}"\
          ": #{e.message}")
  end

  # Check section alphabetization
  if websites != (sites_sort = websites.sort_by { |s| s['name'].downcase })
    error("#{section_file} not ordered by name. Correct order:" \
          "\n" + Diffy::Diff.new(websites.to_yaml, sites_sort.to_yaml, \
                                 context: 10).to_s(:color))
  end

  # Collect list of all images for section
  imgs = Dir["img/#{section['id']}/*"]

  websites.each do |website|
    @total_tracked += 1
    @total_support += 1 unless website['bch'] != true

    next if website['img'].nil?
    test_img("img/#{section['id']}/#{website['img']}", \
             website['name'], imgs)
  end

  # After removing images associated with entries in test_img, alert
  # for unused or orphaned images
  imgs.each do |img|
    next unless img.nil?
    error("#{img} is not used")
  end
end
# rubocop:enable AbcSize,MethodLength

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  sections = YAML.load_file('_data/sections.yml')

  # Check sections.yml alphabetization
  error("#{path} is not alphabetized by name") \
    if sections != (sections.sort_by { |section| section['id'].downcase })
  schema = YAML.load_file(File.join(__dir__, 'websites_schema.yml'))
  validator = Kwalify::Validator.new(schema)

  sections.each do |section|
    process_section(section, validator)
  end

  puts "<--------- Total websites listed: #{@total_tracked} --------->\n"
  puts "<--------- Total websites accepting BCH: #{@total_support} --------->\n"

  @output -= @allowed_output

  exit 1 if @output > 0
rescue Psych::SyntaxError => e
  puts "<--------- ERROR in a YAML file --------->\n"
  puts e
  exit 1
rescue StandardError => e
  puts e
  exit 1
else
  if @allowed_output > 0
    puts "<--------- No build failing errors found! --------->\n"
    puts "<--------- #{@allowed_output} warnings reported! --------->\n"
  else
    puts "<--------- No errors. You\'re good to go! --------->\n"
  end
end
