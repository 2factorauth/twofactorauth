#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json_schemer'

status = 0

schema = JSONSchemer.schema(File.read('tests/schema.json'))
Dir.glob('entries/*/*.json') do |file|
  begin
    JSON.parse(File.read(file))
  rescue JSON::ParserError => e
    puts "::error file=#{file}:: Invalid JSON in #{file}\n#{e.full_message}"
    status = 1
    next
  end

  document = JSON.parse(File.read(file))

  unless schema.valid?(document)
    puts ''
    schema.validate(document).each do |v|
      puts "::error file=#{file}:: #{v['type']} error in in #{file}"
      puts "- tag: #{v['data_pointer'].split('/').last}"
      puts "  data: #{v['data']}"
      puts "  expected: #{v['schema']['pattern']}" if v['type'].eql?('pattern')
      puts "  expected: #{v['schema']['format']}" if v['type'].eql?('format')
    end
    status = 1
  end
end

exit(status)
