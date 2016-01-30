# Load Yaml
require 'yaml'
require 'fastimage'
@output = 0

# Should the script ignore checking for Twitter handles?
@ignore_twitter = 0

# TFA forms
@tfa_forms = %w(email hardware software sms phone)

begin

  # Send error message
  def error(msg)
    @output += 1
    puts "<------------ ERROR ------------>\n" if @output == 1
    puts "#{@output}. #{msg}"
  end

  # Verify that the tfa factors are booleans
  def check_tfa(website)
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

    return if @ignore_twitter
    twitter = website['twitter']
    return if twitter.nil?
    return unless website['tfa']
    error("#{website['name']} should not contain a \'twitter\' tag as it supports TFA.")
  end

  # Load each section, check for errors such as invalid syntax
  # as well as if an image is missing
  main = YAML.load_file('_data/sections.yml')
  main.each do |section|
    data = YAML.load_file('_data/' + section['id'] + '.yml')
    data['websites'].each do |website|
      tfa = "#{website['tfa']}"
      if tfa != 'true' && tfa != 'false'
        error("#{website['name']} \'tfa\' tag should be either \'Yes\' or \'No\'. (#{tfa})")
      end
      check_tfa(website)
      tags_set(website)

      image = "img/#{section['id']}/#{website['img']}"
      if File.exist?(image)
        image_dimensions = [32, 32]

        unless FastImage.size(image) == image_dimensions
          error("#{image} is not #{image_dimensions.join('x')}")
        end

        ext = '.png'
        error("#{image} is not #{ext}") unless File.extname(image) == ext
      else
        error("#{website['name']} image not found.")
      end
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
