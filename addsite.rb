begin
  / methods /

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

  def main
    if question('Is the site you want to add a provider(P) or website(W)?', 'P', 'W')
      qtfa
    else
      $website = true
      qtfa
    end
  end

  def qtfa
    puts "What is the site's name?"
    $name = gets.chomp

    puts "What is the site's URL? (eg. https://twofactorauth.org)"
    $url = gets.chomp.downcase
    if !$url.include? 'http'
      $url.insert(0, 'http://')
    end

    if $website
      puts 'What category fits the site?'
      / TODO: Add to array /
      puts 'Backup, Banking, Cloud, Communication, Crypto, Developer, Domains, Education, Email, Entertainment, Finance, Gaming, Health, Hosting, Identity, Investing, Other, Payments, Remote, Retail, Security, Social'
      $category = gets.chomp.downcase

      if question('Does the site currently support TFA?', 'y', 'n')
        $tfa = true
        tfas
      else
        $tfa = false
      end
    else
      tfas
    end
  end

  def tfas
    if question('Does the site support tfa via SMS?', 'y', 'n')
      $sms = true
    else
      $sms = false
    end
    if question('Does the site support tfa via phone calls?', 'y', 'n')
      $phone = true
    else
      $phone = false
    end
    if question('Does the site support tfa via email?', 'y', 'n')
      $email = true
    else
      $email = false
    end
    if question('Does the site support tfa via hardware tokens?', 'y', 'n')
      $hardware = true
    else
      $hardware = false
    end
    if question('Does the site support tfa via software implementation?', 'y', 'n')
      $software = true
    else
      $software = false
    end

    if $website
      if question('Can you provide a link to some sort of documentation by the site on how to use/set up tfa?', 'y', 'n')
        print 'Please type a link:'
        $docs = gets.chomp.downcase
        if !$docs.include? 'http'
          $docs.insert(0, 'http://')
        end
      else
        /What do?/
      end
    end

  end

  def setup
    /
    TODO: Use the vars provided in tfas and add that to the yaml section.
    /

    if $website
      results = [$name, $url, $category, $tfa, $sms, $phone, $email, $hardware, $software, $docs]
    else
      results = [$name, $url, $sms, $phone, $email, $hardware, $software]
    end
  end

  / script /
  main

end

