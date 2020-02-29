# frozen_string_literal: true

Rake.add_rakelib 'scripts/tasks'
require 'rubocop/rake_task'
require 'jekyll'
require 'safe_yaml/load'
require 'jsonlint/rake_task'

task default: %w[verify rubocop proof jsonlint]
task external: %w[verify rubocop proof_external]

task :build do
  config = Jekyll.configuration(
    'source' => './',
    'destination' => './_site'
  )
  site = Jekyll::Site.new(config)
  Jekyll::Commands::Build.build site, config
end

task proof: 'build' do
  check_site(
    check_html: true,
    disable_external: true,
    hydra: { max_concurrency: 50 }
  )
end

task proof_external: 'build' do
  check_site(
    external_only: true,
    http_status_ignore: [0, 301, 302, 403, 503],
    hydra: { max_concurrency: 20 }
  )
end

JsonLint::RakeTask.new do |t|
  t.paths = %w[_site/data.json _site/stats.json]
end

task :verify do
  ruby './verify.rb'
end

task :clean do
  rm_rf './_site'
end

RuboCop::RakeTask.new

# rubocop:disable Metrics/MethodLength
def check_site(options = {})
  require 'html-proofer'

  dir = jekyll_site_dir
  defaults = {
    assume_extension: true,
    check_favicon: true,
    check_opengraph: true,
    file_ignore: ["#{dir}/google75bd212ec246ba4f.html"],
    url_ignore: ['/add',
                 'https://fonts.gstatic.com/',
                 'https://abs.twimg.com',
                 'https://cdn.syndication.twimg.com',
                 'https://fonts.googleapis.com/',
                 'https://pbs.twimg.com',
                 'https://syndication.twitter.com'],
    cache: { timeframe: '1w' }
  }
  HTMLProofer.check_directory(dir, defaults.merge(options)).run
end
# rubocop:enable Metrics/MethodLength

def jekyll_site_dir
  dir = './_site'
  if File.exist?('_config.yml')
    config = SafeYAML.load_file('_config.yml')
    dir = config['destination'] || dir
  end
  dir
end

def base_dir
  __dir__
end
