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
  require 'highline/import'

  desc 'adding data to the site'

  task :manual do
    listing = {}
    site = {}
    section_file = ''
    loop do
      category = value_prompt('category')
      section_file = File.join(__dir__, "_data/#{category}.yml")
      break if File.exist?(section_file)
    end
    tags_from_schema['mapping'].each do |index|
      data = prompt_tag(index[0], index[1])
      site[index[0]] = data unless data.nil?
    end
    listing['websites'] = [site]
    loop do
      errors = validate_revision(listing)
      break if errors.count.zero?
      extract_paths(errors).each do |path|
        puts "#{path} failed validation, please provide a new value"
        site[path] = value_prompt(path)
      end
      listing['websites'] = [site]
    end

    section = SafeYAML.load_file(section_file)
    websites = section['websites']

    if valid_to_ins(websites, site['name'])
      websites[websites.count] = site
      puts websites.count
      section['websites'] = websites.sort_by { |s| s['name'].downcase }
      if valid_revision(section)
        File.write(section_file, YAML.dump(section))
      else
        puts 'Invalid entry, try changing the data before trying again.'
      end
      puts 'error' unless valid_revision(listing)
      puts listing.to_yaml
    else
      puts 'Duplicate of entry, update functionality not yet available'
    end
  end

  task :github do
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

  # rubocop:disable Semicolon
  def yesno(prompt = 'Continue?', default = true, details = nil)
    a = ''
    s = default ? '[Y/n]' : '[y/N]'
    d = default ? 'y' : 'n'
    puts details unless details.nil?
    until %w[y n].include? a
      a = ask("#{prompt} #{s} ") { |q| q.limit = 1; q.case = :downcase }
      a = d if a.length.zero?
    end
    a == 'y'
  end
  # rubocop:enable Semicolon

  def tags_from_schema
    schema = YAML.load_file(File.join(__dir__, 'websites_schema.yml'))
    Kwalify::Util.traverse_schema(schema) do |rule|
      return rule if rule['name'] == 'Website'
    end
  end

  def extract_paths(errors)
    paths = []
    errors.each do |e|
      paths << e.path.split('/')[3]
    end

    paths
  end

  # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity
  def prompt_tag(column, rule)
    output = nil
    puts '--------------------------------'
    req = (rule['required'] || false)
    if req || yesno("Include #{column} tag?", false, (rule['desc'] || nil))
      rule_type = (rule['type'] || 'str')
      case rule_type

      when 'seq'
        seq = []
        # Add loop around this to ask if we should add one after this first one
        rule['sequence'].each do |e|
          data = if e.length < 2 || !e[1] || e[1].empty?
                   value_prompt("#{column} entry")
                 else
                   prompt_tag(e[0], e[1])
                 end
          seq << data unless data.nil?
        end
        output = seq unless seq.empty?
      when 'map'
        map = {}

        # Add loop around this to ask if we should add one after this first one
        rule['mapping'].each do |e|
          data = if e.length < 2 || !e[1] || e[1].empty?
                   value_prompt("#{column} entry")
                 else
                   prompt_tag(e[0], e[1])
                 end
          map[column] = data unless data.nil?
        end
        output = map unless map.empty?

      when 'bool'
        output = yesno("#{column} value?", rule['default'])

      else
        output = value_prompt(column)
      end
    end

    output
  end
  # rubocop:enable AbcSize, CyclomaticComplexity, PerceivedComplexity

  def valid_to_ins(websites, name)
    websites.each do |site|
      return false if site['name'] == name
    end

    true
  end

  def validate_revision(data)
    schema = YAML.load_file(File.join(__dir__, 'websites_schema.yml'))
    validator = Kwalify::Validator.new(schema)
    errors = validator.validate(data)

    errors
  end

  def valid_revision(data)
    errors = validate_revision(data)

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
    rm_rf './_site/assets' # remove this if we move where our CSS live
    puts 'Building acceptbitcoincash docker image'
    puts `docker build -t acceptbitcoincash/acceptbitcoincash .`
  end
end
