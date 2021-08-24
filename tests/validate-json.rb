#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json_schemer'

status = 0

schema = JSONSchemer.schema(File.read('tests/schema.json'))
categories = JSON.parse(File.read('_data/categories.json')).map { |cat| cat['name'] }

seen_names = []

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
      puts "  expected: #{v['schema']['required']}" if v['type'].eql?('required')
      puts "  expected: only one of 'tfa' or 'contact'" if v['type'].eql?('oneOf')
      puts "  expected: 'tfa' to contain '#{v['schema']['contains']['const']}'" if v['type'].eql?('contains')
    end
    status = 1
  end

  domain = document.values[0]['domain']
  url = document.values[0]['url']
  default_url = "https://#{domain}"
  if !url.nil? && ( url.eql?(default_url) || url.eql?(default_url+"/") )
    puts "::error file=#{file}:: Defining the url property for #{domain} is not necessary - '#{default_url}' is the default value"
    status = 1
  end
  
  keywords = document.values[0]['keywords']
  keywords.each do |kw|
    unless categories.include? kw
      puts "::error file=#{file}:: Invalid keyword: '#{kw}'. See _data/categories.json for a list of valid keywords"
      status = 1
    end
  end
  
  file_name = file.split('/')[2]
  expected_file_name = document.values[0]['domain'] + '.json'

  unless file_name.eql? expected_file_name
    puts "::error file=#{file}::File name should be the same as the domain name.
    Received: #{file_name}. Expected: #{expected_file_name}"
    status = 1
  end
  
  name = document.keys[0]
  if seen_names.include? name
    puts "::error file=#{file}:: An entry with the name '#{name}' already exists. Duplicate site names are not allowed.
    If this entry is not the same site, please rename '#{name}'."
    status = 1
  else
    seen_names.push(name)
  end
end

exit(status)
