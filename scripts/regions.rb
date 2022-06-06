#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'yaml'
require 'parallel'

data_dir = './_data'
categories = JSON.parse(File.read("#{data_dir}/categories.json"))
regions = YAML.load_file("#{data_dir}/regions.yml").map { |r| [r['id'], r] }.to_h
regions['int'] = { 'name' => 'Global' }
tmp_dir = `mktemp -d`.strip

FileUtils.cp_r(Dir.glob('.git'), "#{tmp_dir}/") unless File.exist?("#{tmp_dir}/.git")

# Region loop
Parallel.map(regions.keys) do |key|
  region = regions[key]
  dest_dir = "#{tmp_dir}/#{key}"
  Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
  FileUtils.cp_r(%w[index.html _includes _layouts], dest_dir)
  File.open("#{dest_dir}/_config_region.yml", 'w') do |file|
    file.write("title: 2FA Directory (#{region['name']})") unless key.eql?('int')
  end

  all = {}
  used_categories = []

  # Website loop
  JSON.parse(File.read("#{data_dir}/all.json")).each do |name, website|
    # Ignore if current region is excluded
    next if website['regions']&.select { |r| r.start_with?('-') }&.map! { |rc| rc.tr('-', '') }&.include?(region['id'])
    # Ignore unless regions element includes current region or current region is int
    next unless website['regions']&.reject { |r| r.start_with?('-') }&.include?(key) || key.eql?('int')

    all[name] = website
    website['keywords'].each { |kw| used_categories.push kw }
  end

  FileUtils.mkdir_p("#{dest_dir}/_data")
  File.open("#{dest_dir}/_data/all.json", 'w') { |file| file.write JSON.generate(all) }
  File.open("#{dest_dir}/_data/categories.json", 'w') do |file|
    file.write JSON.generate(categories.select { |cat| used_categories.include? cat['name'] })
  end

  out_dir = "#{Dir.pwd}/_site/#{key}"
  puts "Building #{key}..."
  # rubocop:disable Layout/LineLength
  puts `bundle exec jekyll build -s #{dest_dir} --config _config.yml,#{dest_dir}/_config_region.yml -d #{out_dir} --baseurl #{region['id']}`
  # rubocop:enable Layout/LineLength
  puts "#{key} built."
end
