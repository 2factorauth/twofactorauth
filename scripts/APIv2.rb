#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

tfa = { 'email' => {}, 'hardware' => {}, 'phone' => {}, 'proprietary' => {}, 'sms' => {}, 'totp' => {}, 'u2f' => {} }
rplc_ptrn = { 'call' => 'phone', 'custom-software' => 'proprietary', 'custom-hardware' => 'hardware' }
all = {}

Dir.glob('entries/*/*.json') do |file|
  website = JSON.parse(File.read(file)).values[0]
  name = JSON.parse(File.read(file)).keys[0]
  category = website['keywords'][0]

  entry = {
    'url' => (website['url'].nil? ? "https://#{website['domain']}/" : website['url']),
    'img' => (website['img'].nil? ? "#{website['domain']}.svg" : website['img']),
    'doc' => (website['documentation'] unless website['documentation'].nil?),
    'exception' => (website['notes'] unless website['notes'].nil?)
  }.select { |_, i| i } # Use keep the entries that aren't nil

  entry['tfa'] = website['tfa'].map { |e| rplc_ptrn.keys.include?(e) ? rplc_ptrn[e] : e } unless website['tfa'].nil?
  website['contact']&.each { |a, b| a.eql?('email') ? entry['email_address'] = b : entry[a] = b }

  all[category].nil? ? all[category] = { name => entry } : all[category][name] = entry # Initialize the object
end

# Add 'tfa' hash to tfa hash
tfa['tfa'] = {}

# Sort all entries and add appropriate entries to the tfa object
all.each { |k, v| all[k] = v.sort_by { |entry_name, _| entry_name }.to_h }.each do |ctgry, sites|
  sites.each do |name, website|
    tfa.each do |method, _|
      next if website['tfa'].nil?

      tfa['tfa'][ctgry].nil? ? (tfa['tfa'][ctgry] = { name => website }) : (tfa['tfa'][ctgry][name] = website)
      next unless website['tfa'].include?(method)

      tfa[method][ctgry].nil? ? (tfa[method][ctgry] = { name => website }) : (tfa[method][ctgry][name] = website)
    end
  end
end

# Merge all and tfa, output to separate files
{ 'all' => all }.merge(tfa).each do |file_name, output|
  output.each { |k, v| output[k] = v.sort_by { |entry_name, _| entry_name }.to_h } # Sort output alphabetically
  File.open("api/v2/#{file_name}.json", 'w') { |file| file.write output.to_json }
end
