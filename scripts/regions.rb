#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'yaml'
require 'parallel'

data_dir = './_data'
categories = JSON.parse(File.read("#{data_dir}/categories.json"))
websites = JSON.parse(File.read("#{data_dir}/all.json"))
regions_array = YAML.load_file("#{data_dir}/regions.yml")
regions = regions_array.map { |r| [r['id'], r] }.to_h
regions['int'] = { 'name' => 'Global' }
tmp_dir = '/tmp/2fa'
git_dir = Dir.glob('.git')
FileUtils.cp_r(git_dir, "#{tmp_dir}/") unless File.exist?("#{tmp_dir}/.git")

# Region loop
# rubocop:disable Metrics/BlockLength
Parallel.each(-> { regions.pop || Parallel::Stop }) do |region|
  dest_dir = "#{tmp_dir}/#{region['id']}"
  Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
  files = %w[index.html _includes _layouts]
  FileUtils.cp_r(files, dest_dir)

  File.open("#{dest_dir}/_config_region.yml", 'w') do |file|
    file.write("title: 2FA Directory (#{region['name']})") unless key.eql?('int')
  end

  all = {}
  used_categories = []

  # Website loop
  websites.each do |name, website|
    unless website['regions'].nil?
      site_excluded_regions = website['regions'].select { |r| r.start_with?('-') }.map! { |rc| rc.tr('-', '') }
      website['regions'] = website['regions'].reject { |r| r.start_with?('-') }
      next unless website['regions'].include?(key) || key.eql?('int')
      next if website['regions'].each { |a| regions.keys.include? a } || site_excluded_regions&.include?(region['id'])
    end

    all[name] = website
    website['keywords'].each { |kw| used_categories.push kw }
  end

  FileUtils.mkdir_p("#{dest_dir}/_data")
  File.open("#{dest_dir}/_data/all.json", 'w') { |file| file.write JSON.generate(all) }
  File.open("#{dest_dir}/_data/categories.json", 'w') do |file|
    file.write JSON.generate(categories.select { |cat| used_categories.include? cat['name'] })
  end

  out_dir = "#{Dir.pwd}/_site/#{region['id']}"
  puts "Building #{region['id']}..."
  # rubocop:disable Layout/LineLength
  puts `bundle exec jekyll build -s #{dest_dir} --config _config.yml,#{dest_dir}/_config_region.yml -d #{out_dir} --baseurl #{region['id']}`
  # rubocop:enable Layout/LineLength
  puts "#{region['id']} built."
end
# rubocop:enable Metrics/BlockLength
