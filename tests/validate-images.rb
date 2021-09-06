#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
status = 0

PNG_SIZE = [32, 32].freeze

seen_sites = []

Dir.glob('entries/*/*.json') do |file|
  website = JSON.parse(File.read(file)).values[0]
  path = './img/'

  path += if website['img'].nil?
            "#{website['domain'][0, 1].downcase}/#{website['domain']}.svg"
          else
            "#{website['img'][0, 1]}/#{website['img']}"
          end

  unless File.exist?(path)
    puts "::error file=#{file}:: Image does not exist for #{website['domain']} - #{path} cannot be found"
    status = 1
  end

  if !website['img'].nil? && website['img'].eql?("#{website['domain']}.svg")
    puts "::error file=#{file}:: Defining the img property for #{website['domain']} is not necessary " \
         "- '#{website['img']}' is the default value"
    status = 1
  end

  seen_sites.push(path)
end

Dir.glob('img/*/*') do |file|
  next if file.include? '/icons/'

  unless seen_sites.include? "./#{file}"
    puts "::error file=#{file}:: Unused image at #{file}"
    status = 1
  end

  if file.include? '.png'
    dimensions = IO.read(file)[0x10..0x18].unpack('NN')
    unless dimensions.eql? PNG_SIZE
      puts "::error file=#{file}:: PNGs should be 32x32 in size."
      status = 1
    end
  end
end

exit(status)
