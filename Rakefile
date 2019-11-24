# frozen_string_literal: true

require 'html-proofer'
require 'rubocop/rake_task'
require 'jekyll'
require 'jsonlint/rake_task'

task default: %w[proof verify jsonlint rubocop]

task :build do
  config = Jekyll.configuration(
    'source' => './',
    'destination' => './_site'
  )
  site = Jekyll::Site.new(config)
  Jekyll::Commands::Build.build site, config
end

task :proof do
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    disable_external: true, \
    cache: { timeframe: '2d', storage_dir: '/tmp/html-proofer' }
  ).run
end

task proof_external: 'build' do
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    cache: { timeframe: '1w' }, \
    hydra: { max_concurrency: 12 }
  ).run
end

# rubocop:disable Metrics/LineLength
JsonLint::RakeTask.new do |t|
  t.paths = %w[_site/api/v1/data.json _site/api/v2/all.json _site/api/v2/tfa.json]
end
# rubocop:enable Metrics/LineLength

task :verify do
  ruby '.tests/verify.rb'
end

RuboCop::RakeTask.new
