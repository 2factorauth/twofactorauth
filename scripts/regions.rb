#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'yaml'

data_dir = './_data'
websites = JSON.parse(File.read("#{data_dir}/all.json"))
regions = YAML.load_file("#{data_dir}/regions.yml")
tmp_dir = '/tmp'

git_dir = Dir.glob('.git')
FileUtils.cp_r(git_dir, "#{tmp_dir}/") unless File.exist?("#{tmp_dir}/.git")

# Region loop
regions.each do |region|
  dest_dir = "#{tmp_dir}/#{region['id']}"
  unless File.exist?(dest_dir)
    Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
    files = %w[index.html _includes _layouts _data]
    FileUtils.cp_r(files, dest_dir)
  end

  all = {}

  # Website loop
  websites.each do |name, website|
    all[name] = website if website['regions'].nil? || website['regions'].include?(region['id'].to_s)
  end

  File.open("#{dest_dir}/_data/all.yml", 'w') { |file| file.write JSON.generate(all) }

  out_dir = "#{Dir.pwd}/_site/#{region['id']}"
  puts "Building #{region['id']}..."
  puts `bundle exec jekyll build -s #{dest_dir} --config _config.yml -d #{out_dir} --baseurl #{region['id']}`
  puts "#{region['id']} built."
end
