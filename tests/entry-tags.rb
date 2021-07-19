#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
status = 0

Dir.glob('entries/*/*.json') do |file|
  website = JSON.parse(File.read(file)).values[0]

  if website['tfa'].nil?
    unless website['notes'].nil?
      puts "::error file=#{file}:: 'notes' requires 'tfa' to be set"
      status = 1
    end
    unless website['documentation'].nil?
      puts "::error file=#{file}:: 'documentation' requires 'tfa' to be set"
      status = 1
    end
    unless website['recovery'].nil?
      puts "::error file=#{file}:: 'recovery' requires 'tfa' to be set"
      status = 1
    end
    unless website['custom-software'].nil? && website['custom-hardware'].nil?
      puts "::error file=#{file}:: 'custom-property' requires 'tfa' to be set"
      status = 1
    end
  else
    unless website['contact'].nil?
      puts "::error file=#{file}:: Contact information shouldn't be present when 'tfa' is set"
      status = 1
    end

    if website['custom-software']
      unless website['tfa'].include? 'custom-software'
        puts "::error file=#{file}:: 'tfa' must include 'custom-software' when 'custom-software' is set"
      end
    end
    if website['custom-hardware']
      unless website['tfa'].include? 'custom-hardware'
        puts "::error file=#{file}:: 'tfa' must include 'custom-hardware' when 'custom-hardware' is set"
      end
    end
  end

  if website['tfa'].nil? && website['contact'].nil?
    puts "::error file=#{file}:: One of 'contact' or 'tfa' must be set depending on whether the site supports 2FA"
    status = 1
  end
end

exit(status)
