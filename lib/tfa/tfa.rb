require 'yaml'
require "#{(__FILE__)}/../helpers"

class TFA::TFA

  include ::TFA::Helpers

  def run(params={})
    output_yaml(qtfa)
  end

  private

  def category
    puts 'What category fits the site?'

    categories = Dir['_data/*'].map do |file|
      File.basename(file).split(".yml")
    end.flatten

    puts "Available categories: "

    puts "#{categories.join(",")}\n"

    cat = gets.chomp.downcase
    if categories.include?(cat)
      return cat
    else
      category
    end
  end

  def qtfa(params = {})
    puts "What is the site's name?"
    params["name"] = gets.chomp

    puts "What is the site's URL? (eg. https://twofactorauth.org)"
    params["url"] = gets.chomp.downcase

    if !params["url"].include? 'http'
      params["url"].insert(0, 'http://')
    end

    params["category"] = category

    if question('Does the site currently support TFA?', 'y', 'n')
      params["tfa"] = true
      params = tfas(params)
    else
      params["tfa"] = false
      params = no_tfas(params)
    end

    params
  end

  def no_tfas(params)
    puts "What is the site's twitter handle?"
    twitter= gets.chomp
    twitter.gsub!(/@/,"")
    params["twitter"] = twitter
    params
  end

  def tfas(params)

    params["sms"]      = question('Does the site support tfa via SMS?', 'y', 'n')
    params["phone"]    = question('Does the site support tfa via phone calls?', 'y', 'n')
    params["email"]    = question('Does the site support tfa via email?', 'y', 'n')
    params["hardware"] = question('Does the site support tfa via hardware tokens?', 'y', 'n')
    params["software"] = question('Does the site support tfa via software implementation?', 'y', 'n')

    if question('Can you provide a link to some sort of documentation by the site on how to use/set up tfa?', 'y', 'n')
      puts 'Please type a link:'
      params["docs"] = gets.chomp.downcase
      if !params["docs"].include? 'http'
        params["docs"].insert(0, 'http://')
      end
    end

    params
  end

  def output_yaml(params)

    file = "_data/#{params["category"]}.yml"
    config=::YAML.load_file(file)

    site_config = {
      "name"     => params["name"],
      "tfa"      => params["tfa"],
      "phone"    => params["phone"],
      "url"      => params["url"],
      "sms"      => params["sms"],
      "email"    => params["email"],
      "software" => params["software"],
      "hardware" => params["hardware"],
      "twitter"  => params["twitter"],
      "docs"     => params["docs"]
    }

    #remove nil values
    site_config.reject!{|k,v|v.nil?}

    websites = config["websites"]

    #append the newly provided site details
    websites << site_config

    sort!(websites)

    File.open(file, 'w') do |file|
      file.write(config.to_yaml(indentation:6))
    end

    image_path = "img/#{params["category"]}/#{params["name"]}.png"

    puts "IMPORTANT: Please add 32x32 image into #{image_path}"

  end

end
