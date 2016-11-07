require 'yaml'
require 'fastimage'
@output = 0

# Should the script ignore checking for Twitter handles?
@ignore_twitter = false

# YAML tags that are obligatory to all listed sites.
@obligatory_tags = %w(url img name)

# YAML tags related to TFA 'YES'.
@tfa_yes_tags = %w(doc)

# YAML tags related to TFA 'NO'.
@tfa_no_tags = %w(status twitter facebook email_address)

# TFA forms
@tfa_forms = %w(email hardware software sms phone)

# Image max size (in bytes)
@img_max_size = 2500

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '.png'

# Send error message
def error(msg)
  @output += 1
  puts "<------------ ERROR ------------>\n" if @output == 1
  puts "#{@output}. #{msg}"
end

# Test an individual YAML tag
# rubocop:disable AbcSize,CyclomaticComplexity,MethodLength,PerceivedComplexity
def test_tag(tag, required, tfa_state, website, only_true = false)
  if website[tag].nil? && website['tfa'] == tfa_state && required
    error("#{website['name']}: The required YAML tag \'#{tag}\' tag is "\
          'not present.')
  end
  return if website[tag].nil?
  if website['tfa'] != tfa_state
    error("#{website['name']}: The YAML tag \'#{tag}\' should NOT be "\
          "present when TFA is #{website['tfa'] ? 'enabled' : 'disabled'}.")
  end
  return unless only_true && website[tag] != true
  error("#{website['name']}: The YAML tag \'#{tag}\' should either have"\
        " a value set to \'Yes\' or not be used at all. (Current value:"\
        " \'#{website[tag]}\')")
end
# rubocop:enable PerceivedComplexity

# Check the YAML tags
def test_tags(website)
  tfa = website['tfa']
  # rubocop:disable DoubleNegation
  if !!tfa != tfa
    error("#{website['name']}: The YAML tag \'{tfa}\' should be either "\
          "\'Yes\' or \'No\'. (#{tfa})")
  end
  # rubocop:endable DoubleNegation

  # Test tags that are obligatory
  @obligatory_tags.each do |t|
    next unless website[t].nil?
    error("#{website['name']}: The required YAML tag \'#{t}\' tag is not"\
          ' present.')
  end

  # Test tags associated with TFA 'YES'
  @tfa_yes_tags.each { |tfa_form| test_tag(tfa_form, false, true, website) }

  # Test TFA form tags'
  @tfa_forms.each { |tfa_form| test_tag(tfa_form, false, true, website, true) }

  # Test tags associated with TFA 'NO'
  @tfa_no_tags.each { |tfa_form| test_tag(tfa_form, false, false, website) }
end

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
# rubocop:enable AbcSize,CyclomaticComplexity,MethodLength

begin

  # Load each section, check for errors such as invalid syntax
  # as well as if an image is missing
  sections = YAML.load_file('_data/sections.yml')
  sections.each do |section|
    data = YAML.load_file('_data/' + section['id'] + '.yml')
    websites = data['websites']

    # Check section alphabetization
    error("_data/#{section['id']}.yml is not alphabetized by name") \
      if websites != websites.sort_by { |website| website['name'].downcase }

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each do |website|
      test_tags(website)
      test_img("img/#{section['id']}/#{website['img']}", website['name'],
               imgs)
    end

    # After removing images associated with entries in test_img, alert
    # for unused or orphaned images
    imgs.each { |img| next unless img.nil? error("#{img} is not used") }
  end

  exit 1 if @output > 0

rescue Psych::SyntaxError => e
  puts 'Error in a YAML file.'
  puts e
  exit 1
rescue => e
  puts e
  exit 1
else
  puts 'No errors. You\'re good to go!'
end
