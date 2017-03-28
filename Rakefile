require 'html-proofer'
require 'rubocop/rake_task'
require 'jekyll'

task default: %w[build proof verify rubocop]

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
    cache: { timeframe: '1d' }
  ).run
end

task :verify do
  ruby './verify.rb'
end

RuboCop::RakeTask.new
