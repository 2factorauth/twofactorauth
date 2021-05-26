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
    status.next
    next
  end

  document = JSON.parse(File.read(file))

  unless schema.valid?(document)
    puts '================================='
    puts 'Document not valid:'
    schema.validate(document).each do |v|
      puts "- file: #{file}"
      puts "  error : #{v['type']}"
      puts "  data: #{v['data']}"
      puts "  path: #{v['data_pointer']}"
    end
    status.next
  end
end

exit(status)
