# frozen_string_literal: true

require 'yaml'
require 'fastimage'
require 'kwalify'
require 'diffy'
require 'safe_yaml/load'
@output = 0
@warning = 0
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

# rubocop:disable Metrics/AbcSize
def test_img(img, name, imgs, section)
  # Exception if image file not found
  raise "#{section}: #{name} image not found." unless File.exist?(img)

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

  @warning += 1
end

# rubocop:disable Metrics/MethodLength
def process_section(section, validator)
  section_file = "_data/#{section['id']}.yml"
  data = SafeYAML.load_file(File.join(__dir__, section_file))
  websites = data['websites']
  validate_data(validator, data, section_file, 'name', websites)

  # Set section alphabetization
  data['websites'] = websites.sort_by { |s| s['name'].downcase }
  File.write(File.join(__dir__, section_file), YAML.dump(data))

  # Collect list of all images for section
  imgs = Dir["img/#{section['id']}/*"]

  websites.each do |website|
    @total_tracked += 1
    @total_support += 1 if website['bch'] == true

    next if website['img'].nil?

    test_img("img/#{section['id']}/#{website['img']}", \
             website['name'], imgs, section_file)
  end

  # After removing images associated with entries in test_img, alert
  # for unused or orphaned images
  imgs.each do |img|
    next unless img.nil?

    error("#{img} is not used")
  end
end
# rubocop:enable Metrics/MethodLength

def validate_data(validator, data, file, identifier, subset = nil)
  val = 2
  if subset.nil?
    subset = data if subset.nil?
    val -= 1
  end

  validator.validate(data).each do |e|
    msg = parse_error_msg(e, val, subset)
    error("#{file}:#{subset.at(e.path.split('/')[val].to_i)[identifier]}"\
          ": #{e.message}#{msg}")
  end
end

def parse_error_msg(error, val, subset)
  msg = ''
  if error.message.include? " is already used at '/"
    err_split = error.message.split('already used at')[1].split('/')
    return "\nThese listings share the same "\
          "'#{err_split[val + 1].split('\'')[0]}':"\
          "\n#{subset.at(err_split[val].to_i).to_yaml}"\
          "#{subset.at(error.path.split('/')[val].to_i).to_yaml}\n"
  end

  msg
end
# rubocop:enable Metrics/AbcSize

def validate_schema(parser, schema)
  parser.parse_file(File.join(__dir__, schema))
  errors = parser.errors()
  return unless errors && !errors.empty?

  errors.each do |e|
    error(e.message.to_s)
  end
end

def validate_alphabetical(set, identifier, set_name)
  return unless set != (sorted = set.sort_by { |s| s[identifier].downcase })

  msg = Diffy::Diff.new(set.to_yaml, sorted.to_yaml, context: 10).to_s(:color)
  error("#{set_name} not ordered by #{identifier}. Correct order:#{msg}")
end

def get_validator(schema_name)
  schema = SafeYAML.load_file(File.join(__dir__, schema_name))
  Kwalify::Validator.new(schema)
end

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  # meta validator
  metavalidator = Kwalify::MetaValidator.instance

  # validate schema definition
  parser = Kwalify::Yaml::Parser.new(metavalidator)
  Dir['*_schema.yml'].each do |schema|
    validate_schema(parser, schema)
  end

  validator = get_validator('sections_schema.yml')

  file_name = '_data/sections.yml'
  sections = SafeYAML.load_file(file_name)
  validate_data(validator, sections, file_name, 'id')
  validate_alphabetical(sections, 'id', file_name)

  validator = get_validator('websites_schema.yml')

  sections.each do |section|
    process_section(section, validator)
  end

  puts "<--------- Total websites listed: #{@total_tracked} --------->\n"
  puts "<--------- Total accepting BCH: #{@total_support} --------->\n"

  @output -= @warning

  exit 1 if @output.positive?
rescue Psych::SyntaxError => e
  puts "<--------- ERROR in a YAML file --------->\n"
  puts e
  exit 1
rescue StandardError => e
  puts e
  exit 1
else
  if @warning.positive?
    puts "<--------- No errors found! --------->\n"
    puts "<--------- #{@warning} warning(s) reported! --------->\n"
  else
    puts "<--------- No errors. You\'re good to go! --------->\n"
  end
end
