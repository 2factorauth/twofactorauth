#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

all = {}
tfa = {}
regions = {}
Dir.glob('entries/*/*.json') { |file| all[JSON.parse(File.read(file)).keys[0]] = JSON.parse(File.read(file)).values[0] }

all.sort.to_h.each do |k, v|
  v['tfa']&.each { |method| (tfa[method].nil? ? tfa[method] = { k => v } : tfa[method][k] = v) }
  v['regions']&.each { |region| regions[region] = 1 + regions[region].to_i }
end

{ 'all' => all }.merge(tfa).each do |k, v|
  File.open("api/v3/#{k}.json", 'w') { |file| file.write v.sort_by { |a, _| a.downcase }.to_json }
end

File.open('api/v3/regions.json', 'w') { |file| file.write regions.sort_by(&:last).reverse.to_h.to_json }
# rubocop:disable Layout/LineLength
File.open('api/v3/tfa.json', 'w') { |file| file.write all.select { |_, v| v.key? 'tfa' }.sort_by { |k, _| k.downcase }.to_json }
# rubocop:enable Layout/LineLength
