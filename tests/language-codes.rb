#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

@list_url = 'https://pkgstore.datahub.io/core/language-codes/language-codes_json/data/97607046542b532c395cf83df5185246/language-codes_json.json'
@code_cache = '/tmp/iso-693-1.txt'

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
  JSON.parse(response.body).each { |v| @codes.push(v['alpha2'].downcase) }
  File.open(@code_cache, 'w') { |file| file.write @codes.to_json }
end
status = 0

Dir.glob('entries/*/*.json') do |file|
  website = JSON.parse(File.read(file)).values[0]
  next if website['contact'].nil? || website['contact']['language'].nil?

  lang = website['contact']['language']
  next if @codes.include?(lang)

  begin
    raise("::error file=#{file}:: \"#{lang}\" is not a real ISO 693-1 alpha-2 code.")
  rescue StandardError => e
    puts e.message
    status = 1
  end
end
exit(status)
