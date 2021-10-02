#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'

status = 0
diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"facebook"[^"]*"\\(.*\\)".*/\\1/p'`
@headers = {
  'User-Agent' => '2FactorAuth/FacebookValidator '\
  "(Ruby/#{RUBY_VERSION}; +https://2fa.directory/bot)",
  'From' => 'https://2fa.directory/'
}

diff.split("\n").each do |page|
  url = URI("https://www.facebook.com/pg/#{page}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(url, @headers)
  response = http.request(request)
  begin
    raise("\"#{page}\" is either private or doesn't exist.") if response.code.eql? '404'

    fb_page = response.header['location'].split('/').last
    raise("\"#{page}\" should be \"#{fb_page}\".") unless fb_page.eql? page

    puts("#{page} is valid.")
  rescue StandardError => e
    puts "\e[31m#{e.message}\e[39m"
    status = 1
  end
end
exit status
