#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'yaml'

data_dir = './_data'
tags = %w[url img no_img_border twitter facebook email_address doc exception tfa doc]

# All files to write to
output = {
  'sms' => {},
  'phone' => {},
  'proprietary' => {},
  'totp' => {},
  'hardware' => {},
  'u2f' => {},
  'email' => {},
  'tfa' => {},
  'all' => {}
}

# Loop through all sections
YAML.load_file("#{data_dir}/sections.yml").each do |section|
  # Add section to each output map
  section_name = section['title']
  output.each { |map| map[1][section_name] = {} }

  # Loop through all websites in section
  YAML.load_file("#{data_dir}/#{section['id']}.yml")['websites'].each do |website|
    website_data = {}
    website_name = website['name']

    # Add all tags to website_data unless they're empty
    tags.each { |tag| website_data[tag] = website[tag] unless website[tag].nil? }

    # Write to relevant output maps
    unless website['tfa'].nil?
      website['tfa'].each { |method| output[method][section_name][website_name] = website_data }
      output['tfa'][section_name][website_name] = website_data
    end
    output['all'][section_name][website_name] = website_data
  end
end

# Write to all output files
output.map.each do |k, v|
  File.open("./api/v2/#{k}.json", 'w') { |file| file.write v.to_h.to_json }
end
