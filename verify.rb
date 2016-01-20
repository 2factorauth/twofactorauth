# Load Yaml
require 'yaml'
require 'fastimage'
$output=0;
$ignore_twitter=0;
begin

  # Send error message
  def error(msg)
    $output=$output+1;
    if ($output == 1)
      puts "<------------ ERROR ------------>\n"
    end
    puts "#{$output}. #{msg}"
  end

  # Verify that the tfa factors are booleans
  def check_tfa(website)
    tfa_forms = ['email', 'hardware', 'software', 'sms', 'phone']
    for i in 0..(tfa_forms.length-1)
      form = website[tfa_forms[i]]
      if (form != nil)
        if (form != true)
          error("#{website['name']} should not contain a \'#{tfa_forms[i]}\' tag when it\'s value isn\'t \'YES\'.")
        end
        if (website['tfa'] != true)
          error("#{website['name']} should not contain a \'#{tfa_forms[i]}\' tag when it doesn\'t support TFA.")
        end
      end
    end
  end

  def tags_set(website)
    tags = ['url', 'img', 'name']
    for i in 0..(tags.length-1)
      tag = website[tags[i]]
      if(tag == nil)
        error("#{website['name']} doesn\'t contain a \'#{tags[i]}\' tag.")
      end
    end

    #if(!$ignore_twitter)
      twitter = website['twitter']
      if(twitter != nil)
        if(website['tfa'])
          error("#{website['name']} should not contain a \'twitter\' tag as it supports TFA.")
        end
     # end
    end
  end

  # Load each section, check for errors such as invalid syntax
  # as well as if an image is missing
  main = YAML.load_file('_data/sections.yml')
  main.each do |section|
    data = YAML.load_file('_data/' + section[1]['id'] + '.yml')
    data['websites'].each do |website|
      tfa = "#{website['tfa']}"
      if (tfa != 'true' && tfa != 'false')
        error("#{website['name']} \'tfa\' tag should be either \'Yes\' or \'No\'. (#{tfa})");
      end
      check_tfa(website)
      tags_set(website)


      image = "img/#{section[1]['id']}/#{website['img']}"

      unless File.exists?(image)
        error("#{website['name']} image not found.")
      else

        image_dimensions = [32, 32]

        unless FastImage.size(image) == image_dimensions
          error("#{image} is not #{image_dimensions.join("x")}")
        end

        ext = ".png"
        unless File.extname(image) == ext
          error("#{image} is not #{ext}")
        end
      end
    end
  end

  if ($output > 0)
    exit 1
  end
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
