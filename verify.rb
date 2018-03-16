require 'yaml'
require 'fastimage'
require 'kwalify'
require 'diffy'
@output = 0
@output_soft = 0

# Image max size (in bytes)
@img_recommended_size = 2500
@img_max_size = 3000

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '.png'

# List all section files
@section_files = [
  '_data/sections.yml',
  '_data/adult-sections.yml',
  '_data/donation-sections.yml'
]

# Send error message
def error(msg)
  @output += 1
  puts "  #{@output}. #{msg}"
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
  test_img_size(File.size(img))
end

def test_img_size(file_size)
  return unless file_size > @img_recommended_size

  error("#{img} should not be larger than #{@img_recommended_size} bytes. "\
          "It is currently #{file_size} bytes.")

  @output_soft += 1\
    if file_size < @img_max_size
end
# rubocop:enable AbcSize,CyclomaticComplexity

def process_sections_file(path)
  err_count = @output
  sections = YAML.load_file(path)
  puts "Processing: #{path}\n"

  # Check sections.yml alphabetization
  error("#{path} is not alphabetized by name") \
    if sections != (sections.sort_by { |section| section['id'].downcase })
  schema = YAML.load_file(File.join(__dir__, 'websites_schema.yml'))
  validator = Kwalify::Validator.new(schema)
  sections.each do |section|
    section_file = "_data/#{section['id']}.yml"
    data = YAML.load_file(File.join(__dir__, section_file))
    websites = data['websites']
    errors = validator.validate(data)

    errors.each do |e|
      error("#{section_file}:#{websites.at(e.path.split('/')[2].to_i)['name']}"\
        ": #{e.message}")
    end

    # Check section alphabetization
    error("#{section_file} not ordered by name. Correct order:" \
      "\n" + Diffy::Diff.new(websites.to_yaml, sites_sort.to_yaml, \
                             context: 10).to_s(:color))\
    if websites != (sites_sort = websites.sort_by { |s| s['name'].downcase })

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each do |website|
      test_img("img/#{section['id']}/#{website['img']}", website['name'], \
               imgs) unless website['img'].nil?
    end

    # After removing images associated with entries in test_img, alert
    # for unused or orphaned images
    imgs.each do |img|
      next unless img.nil?
      error("#{img} is not used")
    end
  end

  puts "  No errors found\n" if @output == err_count
end

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  @section_files.each do |file|
    process_sections_file(file)
  end

  @output -= @output_soft

  exit 1 if @output > 0
rescue Psych::SyntaxError => e
  puts "<------------ ERROR in a YAML file ------------>\n"
  puts e
  exit 1
rescue StandardError => e
  puts e
  exit 1
else
  puts "<------------ No errors. You\'re good to go! ------------>\n"
end