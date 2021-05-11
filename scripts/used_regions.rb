#!/bin/ruby
# frozen_string_literal: true

require 'yaml'
require 'json'

regions = {}
YAML.load_file('_data/sections.yml').each do |section|
  YAML.load_file("_data/#{section['id']}.yml")['websites'].each do |website|
    next if website['regions'].nil?

    website['regions'].each { |region| regions[region] = 1 + regions[region].to_i }
  end
end
puts regions.sort_by(&:last).reverse.to_h.to_json
