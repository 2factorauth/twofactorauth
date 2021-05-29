#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

categories = {}
Dir.glob('entries/*/*.json') do |file|
  website = JSON.parse(File.read(file)).values[0]
  name = JSON.parse(File.read(file)).keys[0]

  categories[website['keywords'][0]] = {} if categories[website['keywords'][0]].nil?
  entry = {}

  entry['name'] = name
  entry['url'] = website['url'].nil? ? "https://#{website['domain']}/" : website['url']
  entry['img'] = website['img'].nil? ? "#{website['domain']}.svg" : website['img']
  if website['tfa']
    entry['tfa'] = true
    entry['email'] = true if website['tfa'].include?('email')
    entry['sms'] = true if website['tfa'].include?('sms')
    entry['phone'] = true if website['tfa'].include?('call')
    entry['software'] = true if website['tfa'].include?('totp') || website['tfa'].include?('custom-software')
    entry['hardware'] = true if website['tfa'].include?('u2f') || website['tfa'].include?('custom-hardware')
    entry['doc'] = website['documentation'] unless website['documentation'].nil?
    entry['exceptions'] = { 'text' => website['notes'] } unless website['notes'].nil?
  else
    unless website['contact'].nil?
      entry['twitter'] = website['contact']['twitter'] unless website['contact']['twitter'].nil?
      entry['facebook'] = website['contact']['facebook'] unless website['contact']['facebook'].nil?
      entry['email_address'] = website['contact']['email'] unless website['contact']['email'].nil?
    end
  end

  categories[website['keywords'][0]][name] = entry
end

categories.each { |k, v| categories[k] = v.sort_by { |entry_name, _| entry_name }.to_h }
File.open('api/v1/data.json', 'w') { |file| file.write JSON.generate(categories) }
