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
  require 'html-proofer'
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    check_html: true, \
    disable_external: true, \
    url_ignore: ['/add'], \
    hydra: { max_concurrency: 50 }
  ).run
end

task proof_external: 'build' do
  require 'html-proofer'
  HTMLProofer.check_directory(
    './_site', \
    assume_extension: true, \
    # check_html: true, \
    external_only: true, \
    url_ignore: ['/add'], \
    http_status_ignore: [0, 301, 302, 403, 503], \
    cache: { timeframe: '1w' }, \
    hydra: { max_concurrency: 20 }
  ).run
end

task :verify do
  ruby './verify.rb'
end

task :clean do
  rm_rf './_site'
end

# rubocop:disable MethodLength, BlockLength
namespace :add do
  require 'net/http'
  require 'json'
  require 'yaml'
  require 'safe_yaml/load'
  require 'open-uri'
  require 'kwalify'

  desc 'adding data to the site'

  task :github_listing do
    url = 'https://api.github.com/repos/acceptbitcoincash/acceptbitcoincash/issues/'
    url += value_prompt('issue number')
    uri = URI(url)
    puts 'pulling issue from repository'
    issue = Net::HTTP.get(uri)
    issue = JSON.parse(issue)
    category = get_category(issue['labels'])
    request = SafeYAML.load(extract_issue_yml(issue['body']))[0]

    section_file = File.join(__dir__, "_data/#{category}.yml")
    section = SafeYAML.load_file(section_file)
    websites = section['websites']

    if valid_to_ins(websites, request['name'])
      if request['img'].nil?
        request['img'] = value_prompt('image name')
      elsif request['img'].include? 'http'
        puts "Download the image from #{request['img']}"
        request['img'] = value_prompt('image name')
      end
      puts "Be sure you saved the logo to img/#{category}/#{request['img']}"

      websites[websites.count] = request
      puts websites.count
      section['websites'] = websites.sort_by { |s| s['name'].downcase }
      if valid_revision(section)
        File.write(section_file, YAML.dump(section))
      else
        puts 'Invalid entry, try changing the data before trying again.'
      end
    else
      puts 'Duplicate of entry, update functionality not yet available'
    end
  end

  def valid_to_ins(websites, name)
    websites.each do |site|
      return false if site['name'] == name
    end

    true
  end

  def valid_revision(data)
    schema = YAML.load_file(File.join(__dir__, 'websites_schema.yml'))
    validator = Kwalify::Validator.new(schema)
    errors = validator.validate(data)
    errors.count.zero?
  end

  def get_category(labels)
    puts 'looking for category to insert listing into'
    labels.each do |lbl|
      return lbl['name'].split('/')[1] if lbl['name'].include? 'section/'
    end

    value_prompt('category')
  end

  def value_prompt(text)
    STDOUT.puts "What is the #{text}?"
    STDIN.gets.chomp
  end

  def extract_issue_yml(issue_data)
    process = false
    data = '    '

    issue_data.each_line do |line|
      if line.include? '```yml'
        process = true
      elsif process
        if line.include? '```'
          process = false
        else
          data += line
        end
      end
    end

    data = data.gsub(/[\r\n]+/m, "\n")
    data
  end
end
# rubocop:enable MethodLength, BlockLength

RuboCop::RakeTask.new

namespace :docker do
  desc 'build docker images'
  task :build do
    puts 'Generating static files for nginx'
    puts `bundle exec jekyll build`
    puts 'Building acceptbitcoincash docker image'
    puts `docker build -t acceptbitcoincash/acceptbitcoincash .`
  end
end
