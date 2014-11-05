require 'uri'

class NewEntryService

  def run
    params =
      if question('Is the site you want to add a provider(P) or website(W)?', 'P', 'W')
        qtfa
      else
        @website = true
        qtfa
      end

    output_yaml(params)
  end

  private

  def question(question, a1, a2)
    puts question
    puts a1.upcase + '/' + a2.upcase
    answer = gets.chomp.downcase
    if answer == a1.downcase
      true
    elsif answer == a2.downcase
      return false
    else
      question(question, a1, a2)
    end
  end

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

    if @website
      params["category"] = category

      if question('Does the site currently support TFA?', 'y', 'n')
        params["tfa"] = true
        params = tfas(params)
      else
        params["tfa"] = false
      end
    else
      params = tfas(params)
    end

  end

  def tfas(params)

    params["sms"]      = question('Does the site support tfa via SMS?', 'y', 'n')
    params["phone"]    = question('Does the site support tfa via phone calls?', 'y', 'n')
    params["email"]    = question('Does the site support tfa via email?', 'y', 'n')
    params["hardware"] = question('Does the site support tfa via hardware tokens?', 'y', 'n')
    params["software"] = question('Does the site support tfa via software implementation?', 'y', 'n')

    if @website
      if question('Can you provide a link to some sort of documentation by the site on how to use/set up tfa?', 'y', 'n')
        puts 'Please type a link:'
        params["docs"] = gets.chomp.downcase
        if !params["docs"].include? 'http'
          params["docs"].insert(0, 'http://')
        end
      end
    end

    params
  end

  def output_yaml(params)

    if @website
      file = "_data/#{params["category"]}.yml"
      config=YAML.load_file(file)

      site_config = {
        "name"     => params["name"],
        "phone"    => params["phone"],
        "url"      => params["url"],
        "tfa"      => params["tfa"],
        "sms"      => params["sms"],
        "email"    => params["email"],
        "software" => params["software"],
        "hardware" => params["hardware"],
        "docs"     => params["docs"]
      }

      #remove nil values
      site_config.reject!{|k,v|v.nil?}

      websites = config["websites"]

      #append the newly provided site details
      websites << site_config

      sort!(websites)

      File.open(file, 'w') do |file|
        file.write(YAML.dump(config))
      end

    else
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
        file.write(YAML.dump(config))
      end

    end
  end

  #sort the hash inplace
  def sort!(hash)
    hash.sort! do |x, y|
      x["name"].downcase <=> y["name"].downcase
    end
  end

end
