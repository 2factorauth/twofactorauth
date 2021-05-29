#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

@list_url = 'https://pkgstore.datahub.io/core/country-list/data_json/data/8c458f2d15d9f2119654b29ede6e45b8/data_json.json'
@code_cache = '/tmp/iso-3166.txt'

@codes = []
if File.exist?(@code_cache)
  @codes = JSON.parse(File.read(@code_cache.to_s))
else
  url = URI(@list_url)
  headers = {
    'Accept' => 'application/json',
    'User-Agent' => '2fa-ng (https://github.com/phallobst/2fa-ng.git)'
  }
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url, headers)
  response = https.request(request)

  raise("Request failed. Check URL & API key. (#{response.code})") unless response.code == '200'

  # Get region codes from body & store in cache file
  JSON.parse(response.body).each { |v| @codes.push(v['Code'].downcase) }
  File.open(@code_cache, 'w') { |file| file.write @codes.to_json }
end

@status = true

begin
  Dir.glob('entries/*/*.json') do |file|
    website = JSON.parse(File.read(file)).values[0]
    next if website['regions'].nil?

    website['regions'].each do |region|
      next if @codes.include?(region.to_s)

      puts "::error file=#{file}:: \"#{region}\" is not a real ISO 3166-2 code."
      @status = false
    end
  end
rescue StandardError => e
  puts e.message
  @status = false
end

exit(@status)
