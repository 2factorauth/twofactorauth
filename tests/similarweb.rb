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
  def self.api_key
    key = ENV['SIMILARWEB_API_KEY']
    raise('Similarweb API key not set') if key.nil?

    keys = key.split(' ')
    keys[rand(0..(keys.length - 1))]
  end

  def self.fetch(site)
    response = Net::HTTP.get_response URI("https://api.similarweb.com/v1/similar-rank/#{site}/rank?api_key=#{api_key}")
    raise("#{site} doesn't have a Similarweb ranking") if response.code.eql? '404'
    raise("(#{response.code}) Request failed.") unless response.code.eql? '200'

    rank = JSON.parse(response.body)['similar_rank']['rank']
    Cache.store(site, rank)
    rank
  end
end

status = 0
# Fetch changes
diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"domain"[^"]*"\\(.*\\)".*/\\1/p'`
# Strip and loop through diff
diff.split("\n").each.with_index do |site, i|
  sleep 2 if i.positive?
  domain = Addressable::URI.parse("https://#{site}").host
  rank = Cache.fetch(domain) || Similarweb.fetch(domain)
  failure = rank.to_i > 200_000
  puts "\e[#{failure ? '31' : '32'}m#{domain} - #{rank}\e[39m"
  raise("Global rank #{rank} of #{domain} is above the maximum rank of 200K") if failure
rescue StandardError => e
  puts "\e[31m#{e.message}\e[39m"
  status = 1
end
exit(status)
