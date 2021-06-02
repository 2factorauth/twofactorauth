#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
status = 0

begin
  f = nil
  Dir.glob('entries/*/*.json') do |file|
    f = file
    website = JSON.parse(File.read(file)).values[0]
    path = './img/'
    if website['img'].nil?
      path += website['domain'][0,1].downcase + '/' + website['domain'] + '.svg'
    else
      path += website['img'][0,1] + '/' + website['img']
    end
    raise("Image does not exist for #{website['domain']} \n#{path} cannot be found") unless File.exist?(path)
  end
rescue StandardError => e
  puts ":: error file=#{f}:: #{e.message}"
  status = 1
end

exit(status)