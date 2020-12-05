#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'

api_dir = 'api/v1'
data_dir = './_data'
output = {}

FileUtils.mkdir_p api_dir

# Loop through all sections
# rubocop:disable Metrics/BlockLength
YAML.load_file("#{data_dir}/sections.yml").each do |section|
  section_data = {}
  # Loop through all websites in section
  YAML.load_file("#{data_dir}/#{section['id']}.yml")['websites'].each do |website|
    website_data = {}
    website_data['name'] = website['name']
    website_data['url'] = website['url']
    website_data['img'] = website['img']
    if website['tfa'].nil?
      website_data['tfa'] = false
      website_data['twitter'] = website['twitter'] unless website['twitter'].nil?
      website_data['facebook'] = website['facebook'] unless website['facebook'].nil?
      website_data['email_address'] = website['email_address'] unless website['email_address'].nil?
    else
      website['tfa'].any? do |s|
        website_data['tfa'] = true
        website_data['sms'] = true if s.include?('sms')
        website_data['phone'] = true if s.include?('phone')
        website_data['email'] = true if s.include?('email')
        website_data['software'] = true if s.include?('totp') || s.include?('proprietary')
        website_data['hardware'] = true if s.include?('hardware') || s.include?('u2f')
      end
      website_data['exceptions'] = { 'text' => website['exception'] } unless website['exception'].nil?
      unless website['doc'].nil?
        website_data['doc'] =
          website['doc'].start_with?('/notes/') ? "https://twofactorauth.org#{website['doc']}" : website['doc']
      end
    end
    section_data[website['name']] = website_data
  end
  output[section['title']] = section_data
end
# rubocop:enable Metrics/BlockLength

# Write to all output files
File.open("#{api_dir}/data.json", 'w') { |file| file.write output.to_h.to_json }
