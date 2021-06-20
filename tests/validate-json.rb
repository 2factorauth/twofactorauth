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

    schema.validate(document).each do |v|
      puts ''
      puts "::error file=#{file}::#{v['type'].capitalize} error in in #{file}"
      puts "- tag: #{v['data_pointer'].split('/')[2]}" if v['data_pointer'].split('/').length >= 3
      puts "  data: #{v['data']}" if v['details'].nil?
      puts "  data: #{v['details']}" unless v['details'].nil?
      puts "  expected: #{v['schema']['pattern']}" if v['type'].eql?('pattern')
      puts "  expected: #{v['schema']['format']}" if v['type'].eql?('format')
    end
    status = 1
  end

  file_name = file.split('/')[2]
  expected_file_name = document.values[0]['domain'] + '.json'

  unless file_name.eql? expected_file_name
    puts "::error file=#{file}::File name should be the same as the domain name.
    Received: #{file_name}. Expected: #{expected_file_name}"
    status = 1
  end
end

exit(status)
