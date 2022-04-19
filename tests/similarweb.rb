#!/usr/bin/env ruby
# frozen_string_literal: true

require 'addressable'
require 'fileutils'
require 'json'
require 'net/http'
require 'uri'

# Cache handling
module Cache
  @cache_dir = '/tmp/similarweb/'

  def self.fetch(site)
    path = "#{@cache_dir}#{site}"
    File.read(path) if File.exist?(path)
  end

  def self.store(site, rank)
    FileUtils.mkdir_p(@cache_dir)
    File.open("#{@cache_dir}#{site}", 'w') { |file| file.write rank }
  end
end

# Similarweb API handling
module Similarweb
  def self.connect(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.request(Net::HTTP::Get.new(url, { 'Accept' => 'application/json' }))
  end

  def self.fetch(site)
    apikey = ENV['SIMILARWEB_API_KEY']
    url = URI("https://api.similarweb.com/v1/similar-rank/#{site}/rank?api_key=#{apikey}")
    response = connect(url)
    raise("#{site} doesn't have a Similarweb ranking") if response.code.eql? '404'
    raise("(#{response.code}) Request failed.") unless response.code.eql? '200'

    rank = JSON.parse(response.body)['similar_rank']['rank']
    Cache.store(site, rank)
    rank
  end
end

raise('Similarweb API key not set') if ENV['SIMILARWEB_API_KEY'].nil?

status = 0
# Fetch changes
diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"domain"[^"]*"\\(.*\\)".*/\\1/p'`
# Strip and loop through diff
diff.split("\n").each do |site|
  domain = Addressable::URI.parse("https://#{site}").domain
  rank = Cache.fetch(domain) || Similarweb.fetch(domain)
  raise("#{site} is ranked above the maximum rank of 200K") if rank.to_i > 200_000
rescue StandardError => e
  puts "\e[31m#{e.message}\e[39m"
  status = 1
end
exit(status)
