# Load Yaml
require 'yaml'

begin

    # Load each section, check for errors such as invalid syntax
    # as well as if an image is missing
    main = YAML.load_file('_data/main.yml')
    main["sections"].each do |section|
        data = YAML.load_file('_data/' + section["id"] + '.yml')

        data['websites'].each do |website|
          unless File.exists?("img/#{section['id']}/#{website['img']}")
            raise "#{website['name']} image not found."
          end
        end
    end

    # Load each provider and look for each image
    providers = YAML.load_file('_data/providers.yml')
    providers["providers"].each do |provider|
        unless File.exists?("img/providers/#{provider['img']}")
          raise "#{provider['name']} image not found."
        end
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
