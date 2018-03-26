require 'html-proofer'
require 'rubocop/rake_task'
require 'jekyll'

task default: %w[proof verify rubocop]

task :build do
  config = Jekyll.configuration(
    'source' => './',
    'destination' => './_site'
  )
  site = Jekyll::Site.new(config)
  Jekyll::Commands::Build.build site, config
end

task proof: 'build' do
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    disable_external: true
  ).run
end

task proof_external: 'build' do
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    cache: { timeframe: '1w' }, \
    hydra: { max_concurrency: 12 }, \
    typhoeus: { ssl_verifyhost: 0 }
  ).run
end

task :verify do
  ruby './verify.rb'
end

RuboCop::RakeTask.new
