require 'html-proofer'
require 'rubocop/rake_task'
require 'jekyll'

task default: %w[verify rubocop proof]

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
    disable_external: true, \
    url_ignore: ['/add'], \
    cache: { timeframe: '1d' }, \
    hydra: { max_concurrency: 6 }
  ).run
end

task proof_external: 'build' do
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    external_only: false, \
    url_ignore: ['/add'], \
    http_status_ignore: [0, 301, 302, 403, 503], \
    cache: { timeframe: '1w' }, \
    hydra: { max_concurrency: 15 }
  ).run
end

task :verify do
  ruby './verify.rb'
end

RuboCop::RakeTask.new

namespace :docker do
  desc 'build docker images'
  task :build do
    puts 'Generating stats (HTML partial) of websites supporting Bitcoin Cash'
    Dir.chdir(File.join('.', 'scripts', 'python')) do
      puts `python ./bchAccepted.py`
    end
    puts 'Generating static files for nginx'
    puts `bundle exec jekyll build`
    puts 'Building acceptbitcoincash docker image'
    puts `docker build -t acceptbitcoincash/acceptbitcoincash .`
  end
end
