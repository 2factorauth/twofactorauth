# frozen_string_literal: true

require 'yaml'
require 'fastimage'
require 'kwalify'
require 'diffy'

# YAML tags related to TFA
@tfa_tags = {
  # YAML tags for TFA Yes
  true => %w[doc],
  # YAML tags for TFA No
  false => %w[twitter facebook email_address lang]
}.freeze

# Image max size (in bytes)
@img_max_size_png = 2500
@img_max_size_svg = 10240

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '%w[png svg]'

# Permissions set for all the images in the 'img/' directories.
@img_permissions = %w[644 664 777]

# Send error message
def error(msg, file = nil)
  file = " file=#{file}" unless file.nil?
  raise "::error#{file}:: #{msg}"
end

def test_img(img, name, imgs)
  # Exception if image file not found
  raise "#{name}: image #{img} not found." unless File.exist?(img)

  # Remove img from array unless it doesn't exist (double reference case)
  imgs.delete_at(imgs.index(img)) unless imgs.index(img).nil?

  # Check image dimensions
  error("#{name}: #{img} is not #{@img_dimensions.join('x')} pixels.", img)\
    unless img.match?(/svg$/) or FastImage.size(img) == @img_dimensions

  test_img_file(img, name)
end

# rubocop:disable Metrics/AbcSize
def test_img_file(img, name)
  # Check image file extension and type
  error("#{name}: #{img} is not using a supported image format.", img) \
    unless @img_extension.include?((File.extname(img)[1..-1])) && @img_extension.include?(FastImage.type(img)[1..-1])

  # Check image file size
  img_max_size = img.match?(/svg$/) ? @img_max_size_svg : @img_max_size_png
  unless File.size(img) <= img_max_size
    error("#{name}: #{img} must not be larger than #{img_max_size} bytes. "  \
          "It is currently #{File.size(img)} bytes.", img)
  end

  # Check image permissions
  perms = File.stat(img).mode.to_s(8).split(//).last(3).join
  return if @img_permissions.include?(perms)

  error("#{name}: #{img} permissions must be one of: #{@img_permissions.join(',')}. It is currently #{perms}.", img)
end
# rubocop:enable Metrics/AbcSize

# Load each section, check for errors such as invalid syntax as well as if an image is missing
begin
  sections_file = '_data/sections.yml'
  sections = YAML.load_file(sections_file)

  # Check sections.yml alphabetization
  error('section.yml is not alphabetized by name', sections_file) \
    if sections != (sections.sort_by { |section| section['id'].downcase })

  schema = YAML.load_file('_deployment/tests/websites_schema.yml')
  validator = Kwalify::Validator.new(schema)
  sections.each do |section|
    data_file = "_data/#{section['id']}.yml"
    data = YAML.load_file(data_file)
    websites = data['websites']
    errors = validator.validate(data)

    errors.each { |e| error("#{websites.at(e.path.split('/')[2].to_i)['name']}: #{e.message}") }

    # Check section alphabetization
    if websites != (sites_sort = websites.sort_by { |s| s['name'].downcase })
      error("_data/#{section['id']}.yml is not alphabetical. Correct order:" \
        "\n" + Diffy::Diff.new(websites.to_yaml, sites_sort.to_yaml, \
                               context: 10).to_s(:color), sections_file)
    end

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each do |website|
      @tfa_tags[!website['tfa']].each do |tag|
        next if website[tag].nil?

        error("#{website['name']}: \'#{tag}\' must NOT be present when "\
            "\'tfa\' #{website['tfa'] ? 'is present' : 'is not present'}.")
      end
      test_img("img/#{section['id']}/#{website['img']}", website['name'],
               imgs)
    end

    # After removing images associated with entries in test_img, alert for unused or orphaned images
    imgs.each { |img| error("#{img} is not used", img) unless img.nil? || img.end_with?('webp') }
  end
rescue Psych::SyntaxError => e
  puts "<------------ ERROR in a YAML file ------------>\n"
  puts "::error:: #{e}"
  exit 1
rescue StandardError => e
  puts e.to_s
  exit 1
else
  puts "<------------ No errors. You\'re good to go! ------------>\n"
end
