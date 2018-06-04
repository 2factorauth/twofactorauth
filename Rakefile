require 'rubocop/rake_task'
require 'jekyll'

task default: %w[proof verify rubocop]

dest = './_site'.freeze

task :build do
  config = Jekyll.configuration(
    'source' => './',
    'destination' => dest
  )
  site = Jekyll::Site.new(config)
  Jekyll::Commands::Build.build site, config
end

task proof: 'build' do
  check_site(
    disable_external: true
  )
end

task proof_external: 'build' do
  check_site(
    cache: { timeframe: '1w' },
    hydra: { max_concurrency: 12 }
  )
end

task :verify do
  ruby './verify.rb'
end

RuboCop::RakeTask.new

def check_site(options = {})
  require 'html-proofer'
  defaults = {
    assume_extension: true,
    check_html: true
  }
  HTMLProofer.check_directory(dest, defaults.merge(options)).run
end
