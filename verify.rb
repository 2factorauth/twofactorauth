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

# Should the script ignore checking the image size?
@ignore_image_size = false

# Image max size (in bytes)
@image_max_size = 2500

# Image format used for all images in the 'img/' directories.
@image_extension = ".png"

begin

  # Send error message
  def error(msg)
    @output += 1
    puts "<------------ ERROR ------------>\n" if @output == 1
    puts "#{@output}. #{msg}"
  end

  # Validate an individual YAML tag
  def check_tag(tag, required, tfa_state, website, only_true = false)
    if website[tag].nil?
      if website['tfa'] == tfa_state && required
        error("#{website['name']}: The required YAML tag \'#{tag}\' tag is not present.")
      end
    else
      if website['tfa'] != tfa_state
        state = website['tfa'] ? "enabled" : "disabled"
        error("#{website['name']}: The YAML tag \'#{tag}\' should NOT be present when TFA is #{state}.")
      end
      if only_true && website[tag] != true
        error("#{website['name']}: The YAML tag \'#{tag}\' should either have a value set to \'Yes\' or not be used at all. (Current value: \'#{website[tag]}\')")
      end
    end
  end

  # Validate the YAML tags
  def validate_tags(website)
    tfa = website['tfa']
    if tfa != true && tfa != false
      error("#{website['name']}: The YAML tag \'#{tag}\' should be either \'Yes\' or \'No\'. (#{tfa})")
    end

    # Validate tags that are obligatory
    @obligatory_tags.each do |t|
      tag = website[t]
      next unless tag.nil?
      error("#{website['name']}: The required YAML tag \'#{t}\' tag is not present.")
    end

    # Validate tags associated with TFA 'YES'
    @tfa_yes_tags.each do |tfa_form|
      check_tag(tfa_form, false, true, website)
    end

    # Validate TFA form tags'
    @tfa_forms.each do |tfa_form|
      check_tag(tfa_form, false, true, website, true)
    end

    # Validate tags associated with TFA 'NO'
    @tfa_no_tags.each do |tfa_form|
      check_tag(tfa_form, false, false, website)
    end
  end

  def validate_image(image, name)
    if File.exist?(image)
      image_dimensions = [32, 32]

      unless FastImage.size(image) == image_dimensions
        error("#{image} is not #{image_dimensions.join('x')} pixels.")
      end

      error("#{image} is not using the #{@image_extension} format.") unless File.extname(image) == @image_extension

      unless @ignore_image_size
        image_size = File.size(image)
        error("#{image} should not be larger than #{@image_max_size} bytes. It is currently #{image_size} bytes.") unless image_size <= @image_max_size
      end

    else
      error("#{name} image not found.")
    end
  end

  # Load each section, check for errors such as invalid syntax
  # as well as if an image is missing

  sections = YAML.load_file('_data/sections.yml')
  sections.each do |section|

    data = YAML.load_file('_data/' + section['id'] + '.yml')
    data['websites'].each do |website|

      validate_tags(website)
      validate_image("img/#{section['id']}/#{website['img']}", website['name'])

    end
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
