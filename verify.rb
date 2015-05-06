# Load Yaml
require 'yaml'
require 'fastimage'
$output=0;
$max_size = 2500
$max_size_ignore = false
$error_ignore = false
begin
  def error(msg)
    $output=$output+1;
    if ($output == 1)
      puts "<------------ ERROR ------------>\n"
    end
    puts "#{$output}. #{msg}"

  end

  def image_size_error(msg)
    if ($max_size_ignore == false)
      $output=$output+1;
    end
    puts "#{$output}. #{msg}"
  end

  def check_image(image)
    unless File.exists?(image)
      image_size_error("#{website['name']} image not found.")
    else

      image_dimensions = [32, 32]

      unless FastImage.size(image) == image_dimensions
        image_size_error("#{image} is not #{image_dimensions.join("x")}")
      end

      ext = "\.png"
      unless File.extname(image) == ext
        image_size_error("#{image} is not #{ext}")
      end


      file_size = File.size(image)
      unless file_size < $max_size
        image_size_error("#{image} is larger than #{$max_size} Bytes. (#{file_size} Bytes)")
      end
    end
  end


# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
  main = YAML.load_file('_data/main.yml')
  main["sections"].each do |section|
    data = YAML.load_file('_data/' + section["id"] + '.yml')

    data['websites'].each do |website|
      image = "img/#{section['id']}/#{website['img']}"
      check_image(image)

    end
  end

# Load each provider and look for each image
  providers = YAML.load_file('_data/providers.yml')
  providers["providers"].each do |provider|
    pimage = "img/providers/#{provider['img']}";
    check_image(pimage)
  end

  if ($output > 0 && $error_ignore == false)
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
