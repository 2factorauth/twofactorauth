# frozen_string_literal: true

require 'yaml'
require 'fileutils'

data_dir = './_data'

sections = YAML.load_file("#{data_dir}/sections.yml")
regions = YAML.load_file("#{data_dir}/regions.yml")
tmp_dir = '/tmp'

git_dir = Dir.glob('.git')
FileUtils.cp_r(git_dir, "#{tmp_dir}/") unless File.exist?("#{tmp_dir}/.git")

# Region loop
# rubocop:disable Metrics/BlockLength
regions.each do |region|
  dest_dir = "#{tmp_dir}/#{region['id']}"
  unless File.exist?(dest_dir)
    Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
    files = %w[index.html _includes _layouts _data]
    FileUtils.cp_r(files, dest_dir)
  end

  # Category loop
  sections.each do |section|
    data = YAML.load_file("#{data_dir}/#{section['id']}.yml")
    websites = data['websites']
    section_array = []

    # Website loop
    websites.each do |website|
      if website['regions'].nil?
        section_array.push(website)
        section_array.push(website)
      elsif website['regions'].include?(region['id'].to_s)
      end
    end
    website_array = { websites: section_array }
    website_yaml = website_array.to_yaml.gsub("---\n:", '')

    File.open("#{dest_dir}/_data/#{section['id']}.yml", 'w') do |file|
      file.write website_yaml
    end
  end

  out_dir = "#{Dir.pwd}/#{region['id']}"
  puts "Building #{region['id']}..."
  # rubocop:disable Layout/LineLength
  puts `bundle exec jekyll build -s #{dest_dir} -d #{out_dir} --config _config.yml,_deployment/config-production.yml --baseurl #{region['id']}` # Add -V for debugging
  # rubocop:enable Layout/LineLength
  puts "#{region['id']} built!"
end
# rubocop:enable Metrics/BlockLength
