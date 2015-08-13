# Load Yaml
require 'yaml'
require 'fastimage'
$output=0;
begin
  def error(msg)
    $output=$output+1;
    if($output == 1)
      puts "<------------ ERROR ------------>\n"
    end
    puts "#{$output}. #{msg}"

  end

  # Load each section, check for errors such as invalid syntax
  # as well as if an image is missing
  main = YAML.load_file('_data/main.yml')
  main["sections"].each do |section|
    data = YAML.load_file('_data/' + section["id"] + '.yml')

    data['websites'].each do |website|
      image = "img/#{section['id']}/#{website['img']}"

      unless File.exists?(image)
        error("#{website['name']} image not found.")
      end

      image_dimensions = [32,32]

      unless FastImage.size(image) == image_dimensions
        error("#{image} is not #{image_dimensions.join("x")}")
      end

      ext = ".png"
      unless File.extname(image) == ext
        error("#{image} is not #{ext}")
      end
    end
  end

  if($output > 0 )
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
