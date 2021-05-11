#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'

Dir.glob('img/*/*') do |filename|
  path =  filename.split('/')
  next if path[1].length == 1 || %w[. ..].include?(filename)
  name = path[2].split('')
  puts path[2]
end

