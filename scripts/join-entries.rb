#!/usr/bin/env ruby
# frozen_string_literal: true

# USAGE: ruby ./scripts/join-entries.rb > entries.json

require 'json'

entries = {}
Dir.glob('entries/*/*.json') do |file|
  name = JSON.parse(File.read(file))
  name.each { |k, v| entries[k] = v }
end

puts JSON.generate(entries.sort)
