# Load Yaml
require 'yaml'

begin
# Just load it to see if there are errors
    YAML.load_file('_data/main.yml')
rescue Psych::SyntaxError => e
    puts 'Error in the YAML'
    puts e
    exit 1
else
    puts 'No errors. You\'re good to go!'
end
