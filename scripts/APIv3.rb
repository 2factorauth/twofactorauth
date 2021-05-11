#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

all = {}
tfa = {}
Dir.glob('entries/*/*.json') { |file| all[JSON.parse(File.read(file)).keys[0]] = JSON.parse(File.read(file)).values[0] }
all.sort.to_h.each do |k, v|
  v['tfa']&.each { |method| (tfa[method].nil? ? tfa[method] = { k => v } : tfa[method][k] = v) }
end
{ 'all' => all }.merge(tfa).each { |k, v| File.open("api/v3/#{k}.json", 'w') { |file| file.write v.sort.to_json } }
