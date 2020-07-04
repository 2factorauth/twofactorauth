#!/bin/ruby
# frozen_string_literal: true

require 'json'
require 'yaml'

data_dir = './_data'
sections = YAML.load_file("#{data_dir}/sections.yml")
# map of output
categories = {}

def deep_copy(original)
  Marshal.load(Marshal.dump(original))
end

# Section loop
sections.each { |section| categories[section['title']] = {} }

output = {
  'sms' => deep_copy(categories),
  'phone' => deep_copy(categories),
  'proprietary' => deep_copy(categories),
  'totp' => deep_copy(categories),
  'hardware' => deep_copy(categories),
  'u2f' => deep_copy(categories),
  'email' => deep_copy(categories),
  'tfa' => deep_copy(categories),
  'all' => deep_copy(categories)
}

sections.each do |section|
  sctn_name = section['title']
  # Website loop
  YAML.load_file("#{data_dir}/#{section['id']}.yml")['websites'].each do |website|
    wbst_name = website['name']
    c = {}
    c['url'] = website['url']
    c['img'] = website['img']
    if website['tfa'].nil?
      c['twitter'] = website['twitter'] unless website['twitter'].nil?
      c['facebook'] = website['facebook'] unless website['facebook'].nil?
      c['email_address'] = website['email_address'] unless website['email_address'].nil?
    else
      c['tfa'] = website['tfa']
      c['doc'] = website['doc'] unless website['doc'].nil?
      c['exception'] = website['exception'] unless website['exception'].nil?
      website['tfa'].each do |d|
        output[d][sctn_name][wbst_name] = c
      end
      output['tfa'][sctn_name][wbst_name] = c
    end

    output['all'][sctn_name][wbst_name] = c
  end
end

output.map.each do |k, v|
  File.open("./api/v2/#{k}.json", 'w') { |file| file.write v.to_h.to_json }
end

File.open('./api/v2/all.json', 'w') { |file| file.write output['all'].to_h.to_json }
