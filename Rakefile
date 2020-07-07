# frozen_string_literal: true

require 'html-proofer'
require 'rubocop/rake_task'
require 'jekyll'
require 'jsonlint/rake_task'

task default: %w[proof verify jsonlint rubocop]

task :build do
  config = Jekyll.configuration(
    'source' => './',
    'destination' => './_site',
    'disable_disk_cache' => true
  )
  site = Jekyll::Site.new(config)
  Jekyll::Commands::Build.build site, config
end

task :proof do
  HTMLProofer.check_file(
    './_site/index.html',
    check_html: true,
    empty_alt_ignore: true,
    disable_external: true,
    checks_to_ignore: ['ScriptCheck']
  ).run
end

task proof_external: 'build' do
  HTMLProofer.check_file(
    './_site/index.html', \
    assume_extension: true, \
    check_html: true, \
    cache: { timeframe: '1w' }, \
    hydra: { max_concurrency: 12 }
  ).run
end

JsonLint::RakeTask.new do |t|
  t.paths = %w[_site/api/v1/data.json _site/api/v2/all.json _site/api/v2/tfa.json]
end

task :verify do
  ruby '_deployment/tests/verify.rb'
end

RuboCop::RakeTask.new
