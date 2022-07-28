#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'yaml'
require 'parallel'

data_dir = './_data'
websites = JSON.parse(File.read("#{data_dir}/all.json"))
regions = YAML.load_file("#{data_dir}/regions.yml")
tmp_dir = '/tmp'
regions.insert(0, { 'id' => 'int', 'name' => 'global' })
git_dir = Dir.glob('.git')
FileUtils.cp_r(git_dir, "#{tmp_dir}/") unless File.exist?("#{tmp_dir}/.git")

# Region loop
# rubocop:disable Metrics/BlockLength
# rubocop:disable Layout/LineLength
Parallel.each(-> { regions.pop || Parallel::Stop }) do |region|
  dest_dir = "#{tmp_dir}/#{region['id']}"
  Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
  files = %w[index.html noscript.html _includes _layouts _data]
  FileUtils.cp_r(files, dest_dir)

  File.open("#{dest_dir}/_config_region.yml", 'w') do |file|
    file.write("title: 2FA Directory (#{region['name']})") unless region['id'].eql?('int')
  end

  all = {}
  used_categories = {}

  # Website loop
  websites.each do |name, website|
    unless website['regions'].nil?
      site_regions = website['regions'].reject { |r| r.start_with?('-') }
      site_excluded_regions = website['regions'].select { |r| r.start_with?('-') }.map! { |region_code| region_code.tr('-', '') }
    end

    unless website['regions'].nil? || site_regions.empty? || site_regions.include?(region['id']) || region['id'].eql?('int')
      next
    end

    next if !site_excluded_regions.nil? && site_excluded_regions.include?(region['id'])

    all[name] = website
    website['keywords'].each do |kw|
      used_categories[kw] = true
    end
  end

  File.open("#{dest_dir}/_data/all.json", 'w') { |file| file.write JSON.generate(all) }

  categories = JSON.parse(File.read("#{dest_dir}/_data/categories.json"))

  File.open("#{dest_dir}/_data/categories.json", 'w') do |file|
    file.write JSON.generate(categories.select { |cat| used_categories[cat['name']] })
  end

  out_dir = "#{Dir.pwd}/_site/#{region['id']}"
  puts "Building #{region['id']}..."
  puts `bundle exec jekyll build -s #{dest_dir} --config _config.yml,#{dest_dir}/_config_region.yml -d #{out_dir} --baseurl #{region['id']}`
  puts "#{region['id']} built."
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Layout/LineLength
