require 'yaml'
require "#{(__FILE__)}/../helpers"

module TFA
  class Provider
    include ::TFA::Helpers

    def run(params={})
      output_yaml(questions)
    end

    private

    def questions(params = {})

      puts "What is the provider name?"
      params["name"] = gets.chomp

      puts "What is the provider URL? (eg. https://twofactorauth.org)"
      params["url"] = gets.chomp.downcase

      if !params["url"].include? 'http'
        params["url"].insert(0, 'http://')
      end

      params["sms"]         = question('Does the provider support TFA via SMS?', 'y', 'n')
      params["phone"]       = question('Does the provider support TFA via Phone?', 'y', 'n')
      params["email"]       = question('Does the provider support TFA via Email?', 'y', 'n')
      params["hardware"]    = question('Does the provider provide hardware solution?', 'y', 'n')
      params["software"]    = question('Does the provider software solution?', 'y', 'n')

      params
    end

    def output_yaml(params)

      file = "_data/providers.yml"
      config=::YAML.load_file(file)

      provider_config = {
        "name"          => params["name"],
        "phone"         => params["phone"],
        "url"           => params["url"],
        "sms"           => params["sms"],
        "email"         => params["email"],
        "software"      => params["software"],
        "hardware"      => params["hardware"],
      }

      #remove nil values
      provider_config.reject!{|k,v|v.nil?}

      providers = config["providers"]

      #append the newly provided site details
      providers << provider_config

      sort!(providers)

      File.open(file, 'w') do |file|
        file.write(config.to_yaml(indentation:4))
      end

    end

  end
end
