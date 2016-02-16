# Load Yaml
require 'yaml'
require 'fastimage'
@output = 0

# Should the script ignore checking for Twitter handles?
@ignore_twitter = false

# TFA forms
@tfa_forms = %w(email hardware software sms phone)

# Should the script ignore checking the image size?
@ignore_image_size = false

# Image max size (in bytes)
@image_max_size = 2500

begin

  # Send error message
  def error(msg)
    @output += 1
    puts "<------------ ERROR ------------>\n" if @output == 1
    puts "#{@output}. #{msg}"
  end

  # Verify that the tfa factors are booleans
  def check_tfa(website)
    tfa = website['tfa']
    if tfa != true && tfa != false
      error("#{website['name']} \'tfa\' tag should be either \'Yes\' or \'No\'. (#{tfa})")
    end

    @tfa_forms.each do |tfa_form|
      form = website[tfa_form]
      next if form.nil?
      unless website['tfa']
        error("#{website['name']} should not contain a \'#{tfa_form}\' tag when it doesn\'t support TFA.")
      end
      unless form
        error("#{website['name']} should not contain a \'#{tfa_form}\' tag when it\'s value isn\'t \'YES\'.")
      end
    end
  end

  def tags_set(website)
    tags = %w(url img name)
    tags.each do |t|
      tag = website[t]
      next unless tag.nil?
      error("#{website['name']} doesn\'t contain a \'#{t}\' tag.")
    end

    if website['tfa']
      error("#{website['name']} should not contain a \'status\' tag when it doesn\'t support TFA.") unless website['status'].nil?
    else
      error("#{website['name']} should not contain a \'doc\' tag when it doesn\'t support TFA.") unless website['doc'].nil?
    end

    return if @ignore_twitter
    twitter = website['twitter']
    return if twitter.nil?
    return unless website['tfa']
    error("#{website['name']} should not contain a \'twitter\' tag as it supports TFA.")
  end

  def validate_image(image, name)
    if File.exist?(image)
      image_dimensions = [32, 32]

      unless FastImage.size(image) == image_dimensions
        error("#{image} is not #{image_dimensions.join('x')}")
      end

      ext = '.png'
      error("#{image} is not #{ext}") unless File.extname(image) == ext

      unless @ignore_image_size
        image_size = File.size(image)
        error("#{image} should not be larger than #{@image_max_size} bytes. It is currently #{image_size} bytes") unless image_size < @image_max_size
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

      check_tfa(website)
      tags_set(website)
      validate_image("img/#{section['id']}/#{website['img']}", website['name'])

    end
  end

  exit 1 if @output > 0

rescue Psych::SyntaxError => e
  puts 'Error in the YAML'
  puts e
  exit 1
rescue => e
  puts e
  exit 1
else
  puts 'No errors. You\'re good to go!'
end
