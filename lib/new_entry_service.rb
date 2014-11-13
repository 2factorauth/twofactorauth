require 'uri'
require "#{(__FILE__)}/../tfa"
require "#{(__FILE__)}/../question"

class NewEntryService

  include ::Question

  def run
    params =
      if question('Is the site you want to add a provider(P) or website(W)?', 'P', 'W')
        qtfa
      else
        ::TFA.new.run
      end
  end

  private

  def output_yaml(params)

    file = "_data/providers.yml"
    config=YAML.load_file(file)

    provider_config = {
      "name"     => params["name"],
      "url"      => params["url"],
      "sms"      => params["sms"],
      "phone"    => params["phone"],
      "email"    => params["email"],
      "hardware" => params["hardware"],
      "software" => params["software"],
    }

    #remove nil values
    provider_config.reject!{|k,v|v.nil?}

    providers = config["providers"]

    #append the new provider details
    providers << provider_config

    sort!(providers)

    File.open(file, 'w') do |file|
      file.write(config.to_yaml(indentation:6))
    end

  end

end
