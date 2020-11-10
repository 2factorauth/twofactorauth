#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'uri/http'
require 'addressable/uri'

urls = []
YAML.load_file('_data/sections.yml').each do |section|
  YAML.load_file("_data/#{section['id']}.yml")['websites'].each do |website|
    domain = Addressable::URI.parse(website['url']).host
    raise("::error:: Duplicate entries for #{domain}") if urls.include?(domain)

    urls << domain
  end
end
