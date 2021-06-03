#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
status = 0

accepted_extensions = [".png", ".svg"]

seen_sites = []

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

    unless File.exist?(path)
      puts "::error file=#{file}:: Image does not exist for #{website['domain']} - #{path} cannot be found"
      status = 1
    end

    seen_sites.push(path)

  end

  Dir.glob('img/*/*') do |file|
    f = file

    if !f.include? '/icons/'

      unless seen_sites.include? './' + f
        puts "::error file=#{f}:: Unused image at #{f}"
        status = 1
      end

      unless accepted_extensions.include? File.extname(f)
        puts "::error file=#{f}:: Invalid file extension for #{f}. Only #{accepted_extensions} are allowed"
        status = 1
      end

    end
    
  end

end

exit(status)