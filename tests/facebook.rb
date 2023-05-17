#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'nokogiri'

status = 0
diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"facebook"[^"]*"\\(.*\\)".*/\\1/p'`

@headers = {
  'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) ' \
  'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1',
  'From' => 'https://2fa.directory/'
}

def fetch(handle)
  response = Net::HTTP.get_response(URI("https://m.me/#{handle}"), @headers)
  output = nil
  if response.header['location'] =~ %r{^https://m\.facebook\.com/msg/(\d+|#{handle})/}
    body = Net::HTTP.get_response(URI(response.header['location']), @headers).body
    output = Nokogiri::HTML.parse(body).at_css('._4ag7.img')&.attr('src')
  end
  output
end

diff.split("\n").each do |page|
  raise("Facebook page \"#{page}\" is either private or doesn't exist.") unless fetch(page)

  puts("#{page} is valid.")
rescue StandardError => e
  puts "\e[31m#{e.message}\e[39m"
  status = 1
end

exit status
