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
  used_categories = {}

  # Website loop
  websites.each do |name, website|
    if website['regions'].nil? || website['regions'].include?(region['id'].to_s)
      all[name] = website
      website['keywords'].each do |kw|
        used_categories[kw] = true
      end
    end
  end

  File.open("#{dest_dir}/_data/all.json", 'w') { |file| file.write JSON.generate(all) }

  categories = JSON.parse(File.read("#{dest_dir}/_data/categories.json"))

  File.open("#{dest_dir}/_data/categories.json", 'w') {
    |file| file.write JSON.generate(categories.select{ |cat| used_categories[cat['name']] } ) }

  out_dir = "#{Dir.pwd}/_site/#{region['id']}"
  puts "Building #{region['id']}..."
  puts `bundle exec jekyll build -s #{dest_dir} --config _config.yml -d #{out_dir} --baseurl #{region['id']}`
  puts "#{region['id']} built."
end
