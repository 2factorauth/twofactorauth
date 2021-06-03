#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
status = 0

accepted_extensions = %w[.png .svg]

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

  seen_sites.push(path)
end

Dir.glob('img/*/*') do |file|
  next if file.include? '/icons/'

  unless seen_sites.include? "./#{file}"
    puts "::error file=#{file}:: Unused image at #{file}"
    status = 1
  end

  unless accepted_extensions.include? File.extname(file)
    puts "::error file=#{file}:: Invalid file extension for #{file}. Only #{accepted_extensions} are allowed"
    status = 1
  end
end

exit(status)
