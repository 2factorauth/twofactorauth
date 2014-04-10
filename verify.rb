# Load Yaml
require 'yaml'

begin
# Just load it to see if there are errors
    main = YAML.load_file('_data/main.yml')
    main["sections"].each do |section|
        data = YAML.load_file('_data/' + section["id"] + '.yml')

        data['websites'].each do |website|
          unless File.exists?("img/#{section['id']}/#{website['img']}")
            raise "#{website['name']} image not found."
          end
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
