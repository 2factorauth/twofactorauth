#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'uri/http'
require 'addressable/uri'

urls = []
errors = false
YAML.load_file('_data/sections.yml').each do |section|
  YAML.load_file("_data/#{section['id']}.yml")['websites'].each do |website|
    begin
      domain = Addressable::URI.parse(website['url']).host
      raise("Duplicate entries for #{domain}") if urls.include?(domain)

      urls << domain
    rescue StandardError => e
      print "\e[31m::error:: #{e}\e[39m\n"
      errors ||= true
    end
  end
end

exit(1) if errors
