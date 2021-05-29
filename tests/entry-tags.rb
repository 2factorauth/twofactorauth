#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
begin
  f = nil
  Dir.glob('entries/*/*.json') do |file|
    f = file
    website = JSON.parse(File.read(file)).values[0]
    if website['tfa'].nil?
      raise('"notes" requires "tfa" to be set.') unless website['notes'].nil?
    else
      raise('Contact information shouldn\'t be present when "tfa" is set.') unless website['contact'].nil?
    end
  end
rescue StandardError => e
  puts ":: error file=#{f}:: #{e.message}"
end
