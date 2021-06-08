# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :add do
  require 'net/http'
  require 'json'
  require 'yaml'
  require 'safe_yaml/load'
  require 'open-uri'
  require 'kwalify'
  require 'highline/import'

  desc 'adding data to the site'

  task :category do
    categories = read_yaml('sections')
    new_section = new_entry('sections_schema.yml', 'category')
    unless valid_to_ins(categories, new_section, 'id')
      puts 'Entry invalid to insert'
      return
    end

    write_yaml('sections', add_and_sort(categories, new_section, 'id'))
    make_new_category_file(new_section['id'])
  end

  # rubocop:disable Lint/UselessAssignment
  # disable rubocop on this until completed
  task :keywords do
    category = prompt_category
    section, websites = read_yaml(category, 'websites')
    site = extract_value_set(websites, 'name')
    site.each_with_index do |value, index|
      puts "#{index}: #{value}"
    end
  end
  # rubocop:enable Lint/UselessAssignment
  # rubocop:disable Metrics/MethodLength
  task :manual do
    listing = {}
    site = {}
    category = prompt_category
    site = new_entry('websites_schema.yml', 'site')
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

    section, websites = read_yaml(category, 'websites')
    unless valid_to_ins(websites, site, 'name')
      puts 'Duplicate of entry, update functionality not yet available'
      return
    end

    section['websites'] = add_and_sort(websites, site, 'name')
    if valid_revision(section)
      write_yaml(category, section)
    else
      puts 'Invalid entry, try changing the data before trying again.'
    end
  end

  task :github do
    issue_num = value_prompt('issue number')
    add_from_github(issue_num)
  end

  task :githubs do
    issue_nums = value_prompt('issue numbers (separated by commas)')
    commit_msg = ''
    issue_nums.split(',').each do |num|
      commit_msg += " closes ##{num}" if add_from_github(num)
    end
    puts "Be sure to mention the following when you commit: #{commit_msg}"
  end

  def add_and_sort(list, new_entry, identifier)
    list[list.count] = new_entry
    puts "Entry count now #{list.count}"
    list.sort_by { |s| s[identifier].downcase }
  end

  def prompt_category
    category = ''
    loop do
      category = value_prompt('category')
      section_file = File.join(base_dir, "_data/#{category}.yml")
      break if File.exist?(section_file)
    end

    category
  end

  # rubocop:disable Style/Semicolon
  def yesno(prompt: 'Continue?', default: true, details: nil)
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
  # rubocop:enable Style/Semicolon

  def new_entry(schema_file, class_name)
    entry = {}
    tags = tags_from_schema(schema_file, class_name)
    tags['mapping'].each do |tag|
      data = prompt_tag(tag[0], tag[1])
      entry[tag[0]] = data unless data.nil?
    end

    tag
  end

  def tags_from_schema(schema_file, class_name)
    schema = SafeYAML.load_file(File.join(base_dir, schema_file))
    Kwalify::Util.traverse_schema(schema) do |rule|
      return rule if rule['class'] == class_name
    end
  end

  def extract_value_set(set, attr)
    ret = []
    set.each do |s|
      ret << s[attr]
    end

    ret
  end

  def extract_paths(errors)
    paths = []
    errors.each do |e|
      paths << e.path.split('/')[3]
    end

    paths
  end

  # Safely make a new category file
  def make_new_category_file(category)
    base_yaml = {}
    base_yaml['websites'] = nil
    write_yaml(category, base_yaml) \
      unless File.exist?(File.join(base_dir, "_data/#{category}.yml"))
  end

  def read_yaml(set_name, subset = nil)
    data = SafeYAML.load_file(File.join(base_dir, "_data/#{set_name}.yml"))
    return data, data[subset] unless subset.nil?

    data
  end

  def write_yaml(set_name, set_data)
    new_file = File.join(base_dir, "_data/#{set_name}.yml")
    File.write(new_file, YAML.dump(set_data))
  end

  def img_exists?(category, img_name)
    File.exist?(File.join(base_dir, "img/#{category}/#{img_name}"))
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def add_from_github(issue_num)
    github_url = 'https://api.github.com/repos/acceptbitcoincash/acceptbitcoincash/issues'
    uri = URI("#{github_url}/#{issue_num}")
    puts 'pulling issue from repository'
    issue = Net::HTTP.get(uri)
    issue = JSON.parse(issue)
    category = get_category(issue['labels'])
    request = SafeYAML.load(extract_issue_yml(issue['body']))[0]

    section, websites = read_yaml(category, 'websites')
    unless valid_to_ins(websites, request, 'name')
      puts 'Duplicate of entry, update functionality not yet available'
      return false
    end

    if request['img'].nil?
      request['img'] = value_prompt("image name for #{request['name']}")
    elsif request['img'].include? 'http'
      puts "Download the image from #{request['img']}"
      request['img'] = value_prompt('image name')
    end
    puts "Be sure you saved the logo to img/#{category}/#{request['img']}" \
      unless img_exists?(category, request['img'])

    section['websites'] = add_and_sort(websites, request, 'name')
    if valid_revision(section)
      write_yaml(category, section)
      true
    else
      puts 'Invalid entry, try changing the data before trying again.'
      false
    end
  end

  def prompt_tag(column, rule)
    output = nil
    puts '--------------------------------'
    req = (rule['required'] || false)
    if req || yesno(prompt: "Include #{column} tag?", default: false, details: (rule['desc'] || nil))
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
        output = yesno(prompt: "#{column} value?", default: rule['default'])

      else
        output = value_prompt(column)
      end
    end

    output
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def valid_to_ins(list, new_entry, identifier)
    id = new_entry[identifier]
    list.each do |entry|
      return false if entry[identifier] == id
    end

    true
  end

  def validate_revision(data)
    schema = SafeYAML.load_file(File.join(base_dir, 'websites_schema.yml'))
    validator = Kwalify::Validator.new(schema)
    validator.validate(data)
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
    $stdout.puts "What is the #{text}?"
    $stdin.gets.chomp
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

    data.gsub(/[\r\n]+/m, "\n")
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength
