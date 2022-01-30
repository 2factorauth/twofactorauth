#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'yaml'

all = {}
tfa = {}
regions = {}
Dir.glob('entries/*/*.json') { |file| all[JSON.parse(File.read(file)).keys[0]] = JSON.parse(File.read(file)).values[0] }

all.sort.to_h.each do |k, v|
  v['tfa']&.each { |method| (tfa[method].nil? ? tfa[method] = { k => v } : tfa[method][k] = v) }
  v['regions']&.each do |region|
    next if region[0] == '-'

    regions[region] = {} unless regions.key? region
    regions[region]['count'] = 1 + regions[region]['count'].to_i
  end
end

avail_regions = YAML.load_file('_data/regions.yml').group_by { |hash| hash['id'] }.keys
regions.each { |k, v| v['selection'] = avail_regions.include? k }

{ 'all' => all }.merge(tfa).each do |k, v|
  File.open("api/v3/#{k}.json", 'w') { |file| file.write v.sort_by { |a, _| a.downcase }.to_json }
end

regions['int'] = { 'count' => all.length, 'selection' => true }

File.open('api/v3/regions.json', 'w') { |file| file.write regions.sort_by { |_, v| v['count'] }.reverse!.to_h.to_json }
File.open('api/v3/tfa.json', 'w') do |file|
  file.write all.select { |_, v| v.key? 'tfa' }.sort_by { |k, _| k.downcase }.to_json
end
