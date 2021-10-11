#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

@status = 0
PNG_SIZE = [[32, 32], [64, 64], [128, 128]].freeze
seen_sites = []

def error(msg)
  puts "::error file=#{@file}:: #{msg}"
  @status = 1
end

Dir.glob('entries/*/*.json') do |file|
  @file = file
  website = JSON.parse(File.read(file)).values[0]
  domain = website['domain']
  img = website['img']
  path = "img/#{img.nil? ? "#{domain[0, 1].downcase}/#{domain}.svg" : "#{img[0, 1]}/#{img}"}"

  error("Image does not exist for #{domain} - #{path} cannot be found.") unless File.exist?(path)

  if img.eql?("#{domain}.svg")
    error("Defining the img property for #{domain} is not necessary. #{img} is the default value.")
  end

  seen_sites.push(path)
end

Dir.glob('img/*/*') do |file|
  next if file.include? '/icons/'

  error("Unused image at #{file}") unless seen_sites.include? file

  if file.include? '.png'
    dimensions = IO.read(file)[0x10..0x18].unpack('NN')
    unless PNG_SIZE.include? dimensions
      error("PNGs must be one of the following sizes: #{PNG_SIZE.map { |a| a.join('x') }.join(', ')}.")
    end
  end
end

exit(@status)
