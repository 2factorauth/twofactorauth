Rake.add_rakelib 'scripts/tasks'
require 'rubocop/rake_task'
require 'jekyll'

task default: %w[verify rubocop proof]
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

task :verify do
  ruby './verify.rb'
end

task :clean do
  rm_rf './_site'
end

RuboCop::RakeTask.new

def check_site(options = {})
  require 'html-proofer'

  defaults = {
    assume_extension: true,
    check_favicon: true,
    check_opengraph: true,
    url_ignore: ['/add', 'https://fonts.gstatic.com/'],
    cache: { timeframe: '1w' }
  }
  HTMLProofer.check_directory(jekyll_site_dir, defaults.merge(options)).run
end

def jekyll_site_dir
  dir = './_site'
  if File.exist?('_config.yml')
    config = YAML.load_file('_config.yml')
    dir = config['destination'] || dir
  end
  dir
end

def base_dir
  __dir__
end
