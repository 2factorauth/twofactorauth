#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'fileutils'

# rubocop:disable Metrics/AbcSize
def fetch_from_api(site)
  url = URI("https://awis.api.alexa.com/api?Action=UrlInfo&ResponseGroup=Rank&Output=json&Url=#{site}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  headers = { 'x-api-key' => ENV['ALEXA_API_KEY'], 'Accept' => 'application/json' }
  response = http.request(Net::HTTP::Get.new(url, headers))
  raise("(#{response.code}) Request failed.") unless response.code == '200'

  rank = JSON.parse(response.body)['Awis']['Results']['Result']['Alexa']['TrafficData']['Rank']
  store_cache(site, rank)
  raise("#{site} doesn't have an Alexa ranking") if rank.nil?
  raise("#{site} is ranked above the maximum rank of 200K") if rank.to_i > 200_000
end

# rubocop:enable Metrics/AbcSize

def fetch_from_cache(site)
  path = "/tmp/alexa/#{site}"
  return false unless File.exist?(path)

  rank = File.read(path)
  raise("#{site} doesn't have an Alexa ranking") if rank.eql?('')
  raise("#{site} is ranked above the maximum rank of 200K") if rank.to_i > 200_000

  rank
end

def store_cache(site, rank)
  FileUtils.mkdir_p('/tmp/alexa/')
  File.open("/tmp/alexa/#{site}", 'w') { |file| file.write rank }
end

status = 0
# Fetch changes
diff = `git diff origin/main...HEAD entries/ | grep "^+[[:space:]]*\\"domain\\":" | cut -c17-`
# Strip and loop through diff
diff.gsub("\n", '').split('",').each do |site|
  begin
    fetch_from_api(site) unless fetch_from_cache(site)
  rescue StandardError => e
    puts "\e[31m#{e.message}\e[39m"
    status = status.next
  end
end
exit(status)
