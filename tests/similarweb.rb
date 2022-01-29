#!/usr/bin/env ruby
# frozen_string_literal: true

require 'addressable'
require 'uri'
require 'net/http'
require 'json'
require 'fileutils'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def fetch_from_api(site)
  apikey = ENV['SIMILARWEB_API_KEY']
  url = URI("https://api.similarweb.com/v1/similar-rank/#{site}/rank?api_key=#{apikey}")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  headers = { 'Accept' => 'application/json' }
  response = http.request(Net::HTTP::Get.new(url, headers))
  raise("(#{response.code}) Request failed.") unless response.code == '200'

  rank = JSON.parse(response.body)['similar_rank']['rank']
  store_cache(site, rank)
  raise("#{site} doesn't have a Similarweb ranking") if rank.nil?
  raise("#{site} is ranked above the maximum rank of 200K") if rank.to_i > 200_000
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

def fetch_from_cache(site)
  path = "/tmp/similarweb/#{site}"
  return false unless File.exist?(path)

  rank = File.read(path)
  raise("#{site} doesn't have a Similarweb ranking") if rank.eql?('')
  raise("#{site} is ranked above the maximum rank of 200K") if rank.to_i > 200_000

  rank
end

def store_cache(site, rank)
  FileUtils.mkdir_p('/tmp/similarweb/')
  File.open("/tmp/similarweb/#{site}", 'w') { |file| file.write rank }
end

status = 0
# Fetch changes
diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"domain"[^"]*"\\(.*\\)".*/\\1/p'`
# Strip and loop through diff
diff.split("\n").each do |site|
  domain = Addressable::URI.parse("https://#{site}").domain
  fetch_from_api(domain) unless fetch_from_cache(domain)
rescue StandardError => e
  puts "\e[31m#{e.message}\e[39m"
  # status = 1
end
exit(status)
