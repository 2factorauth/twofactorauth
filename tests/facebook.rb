#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'

status = 0
# rubocop:disable Layout/LineLength
diff = `git diff origin/master...HEAD entries/ | grep "^+[[:space:]]*\\"facebook\\":" | sed -n 's/.*"facebook"[^"]*"\\(.*\\)".*/\\1/p'`
# rubocop:enable Layout/LineLength
diff.gsub("\n", '').gsub(',', '').split('"').each do |page|
  url = URI("https://www.facebook.com/pg/#{page}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  response = http.request(Net::HTTP::Get.new(url))
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
