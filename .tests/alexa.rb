# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'fileutils'

max_ranking = 200_000
max_ranking_string = max_ranking.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse

if ARGV.empty?
  warn 'Usage: alexa.rb url'
  exit(-1)
end

site = ARGV[0]

if File.exist?("/tmp/alexa/#{site}.txt")
  rank = File.open("/tmp/alexa/#{site}.txt", &:readline).delete(' ')
  # Prettify rank
  rank = rank.to_i.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse
else
  url = URI("https://awis.api.alexa.com/api?Action=UrlInfo&ResponseGroup=Rank&Output=json&Url=#{site}")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request['x-api-key'] = ENV['alexa_access_key']
  request['Accept'] = 'application/json'
  response = https.request(request)

  unless response.code == '200'
    raise("Request failed. Check URL & API key. (#{response.code})")
  end

  # Parse response
  body = JSON.parse(response.body)
  body = body['Awis']['Results']['Result']['Alexa']['TrafficData']

  # Prettify body['Rank'] output
  rank = body['Rank'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse

  # Create cache file
  FileUtils.mkdir_p '/tmp/alexa'
  file = File.new("/tmp/alexa/#{site}.txt", 'w')
  file.puts(rank)
  file.close
end

# rubocop:disable Layout/LineLength
raise("\e[31m#{site} has an Alexa ranking above #{max_ranking_string}. (Currently: #{rank})\e[0m") if max_ranking < rank.to_i

raise("\e[31m#{site} doesn't have an Alexa rank. #{max_ranking_string} or less required.\e[0m") if rank.to_i.zero?

# rubocop:enable Layout/LineLength

puts("\e[32m#{site} has an Alexa ranking of #{rank}.\e[0m")
