#!/usr/bin/env ruby
# frozen_string_literal: true

# USAGE: ruby ./scripts/join-entries.rb > entries.json

require 'json'

entries = []

Dir.glob('entries/*/*.json') do |file|
  entry = JSON.parse(File.read(file))
  entries.push([entry.keys[0], entry.values[0]])
end

puts JSON.generate(entries.sort_by { |a| a[0].downcase })
