#!/usr/bin/env ruby
# frozen_string_literal: true

require 'parallel'
require 'json'
require 'net/http'
require 'uri'

url = URI('https://raw.githubusercontent.com/2factorauth/frontend/master/data/categories.json')
response = Net::HTTP.get url

avail_categories = JSON.parse(response).keys

Parallel.each(Dir.glob('entries/*/*.json')) do |file|
  entry = JSON.parse(File.read(file)).values[0]
  categories = entry['categories']
  categories.each do |category|
    raise "::error file=#{file}:: Unknown category '#{category}'" unless avail_categories.include? category
  end
end
