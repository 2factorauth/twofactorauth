require 'yaml'
require 'fastimage'
require 'kwalify'
require 'rugged'
require 'hashdiff'
require 'mailchimp'
@output = 0

# YAML tags related to TFA
@tfa_tags = {
  # YAML tags for TFA Yes
  true => %w[email hardware software sms phone doc],
  # YAML tags for TFA No
  false => %w[status twitter facebook email_address lang]
}.freeze

# Image max size (in bytes)
@img_max_size = 2500

# Image dimensions
@img_dimensions = [32, 32]

# Image format used for all images in the 'img/' directories.
@img_extension = '.png'

# Permissions set for all the images in the 'img/' directories.
@img_permissions = %w[644 664]

# Send error message
def error(msg)
  @output += 1
  puts "<------------ ERROR ------------>\n" if @output == 1
  puts "#{@output}. #{msg}"
end

def test_img(img, name, imgs)
  # Exception if image file not found
  raise "#{name} image not found." unless File.exist?(img)

  # Remove img from array unless it doesn't exist (double reference case)
  imgs.delete_at(imgs.index(img)) unless imgs.index(img).nil?

  # Check image dimensions
  error("#{img} is not #{@img_dimensions.join('x')} pixels.")\
    unless FastImage.size(img) == @img_dimensions

  test_img_file(img)
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def test_img_file(img)
  # Check image file extension and type
  error("#{img} is not using the #{@img_extension} format.")\
    unless File.extname(img) == @img_extension && FastImage.type(img) == :png

  # Check image file size
  img_size = File.size(img)
  unless img_size <= @img_max_size
    error("#{img} should not be larger than #{@img_max_size} bytes. It is"\
              " currently #{img_size} bytes.")
  end

  # Check image permissions
  perms = File.stat(img).mode.to_s(8).split(//).last(3).join
  # rubocop:disable Style/GuardClause
  unless @img_permissions.include?(perms)
    error("#{img} permissions must be one of: #{@img_permissions.join(',')}. "\
    "It is currently #{perms}.")
  end
  # rubocop:enable Style/GuardClause
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

# Load each section, check for errors such as invalid syntax
# as well as if an image is missing
begin
  sections = YAML.load_file('_data/sections.yml')
  # Check sections.yml alphabetization
  error('section.yml is not alphabetized by name') \
    if sections != (sections.sort_by { |section| section['id'].downcase })
  schema = YAML.load_file('websites_schema.yml')
  validator = Kwalify::Validator.new(schema)
  sections.each do |section|
    data = YAML.load_file("_data/#{section['id']}.yml")
    websites = data['websites']
    errors = validator.validate(data)

    errors.each do |e|
      error("#{websites.at(e.path.split('/')[2].to_i)['name']}: #{e.message}")
    end

    # Check section alphabetization
    error("_data/#{section['id']}.yml is not alphabetized by name") \
      if websites != (websites.sort_by { |website| website['name'].downcase })

    # Collect list of all images for section
    imgs = Dir["img/#{section['id']}/*"]

    websites.each do |website|
      @tfa_tags[!website['tfa']].each do |tag|
        next if website[tag].nil?

        error("\'#{tag}\' should NOT be "\
            "present when tfa: #{website['tfa'] ? 'true' : 'false'}.")
      end
      test_img("img/#{section['id']}/#{website['img']}", website['name'],
               imgs)
    end

    # After removing images associated with entries in test_img, alert
    # for unused or orphaned images
    imgs.each { |img| next unless img.nil? error("#{img} is not used") }
  end

  exit 1 if @output > 0
rescue Psych::SyntaxError => e
  puts "<------------ ERROR in a YAML file ------------>\n"
  puts e
  exit 1
# rubocop:disable Style/RescueStandardError
rescue => e
  puts e
  exit 1
# rubocop:enable Style/RescueStandardError
else
  puts "<------------ No errors. You\'re good to go! ------------>\n"
end
if ENV['TRAVIS_EVENT_TYPE'] == 'cron' && \
   ENV['TRAVIS_SECURE_ENV'] == 'true' && Date.today.monday?
  puts 'Sending weekly diff email'
  # Find commits 1 week old
  repo = Rugged::Repository.new('.')
  walker = Rugged::Walker.new(repo)
  walker.push(repo.head.target)
  commit_to_diff = nil
  walker.each do |commit|
    commit_to_diff = commit if Date.today - 7 < Date.parse(commit.time.inspect)
    break if Date.today - 7 >= Date.parse(commit.time.inspect)
  end
  ymls = repo.head.target.diff(commit_to_diff).deltas.map do |d|
    d.new_file[:path]
  end
  ymls.map! { |y| Pathname.new(y).each_filename.to_a }
  ymls.select! { |y| y[0] == '_data' && y[1] != 'sections.yml' }
  ymls.map! { |y| y[1] }
  outputs = []
  ymls.each do |y|
    yml_oid = repo.lookup(commit_to_diff.tree['_data'][:oid])[y][:oid]
    old_content = YAML.safe_load(repo.lookup(yml_oid).content)
    curr_content = YAML.load_file("_data/#{y}")
    HashDiff.diff(old_content, curr_content).each do |d|
      websites_regex = /(?<=websites\[).*(?=\])/

      next unless d[0] == '+' && d[1] =~ websites_regex

      outputs.push(curr_content['websites'][websites_regex.match(d[1]).to_s.to_i])
      puts outputs
      if curr_content['websites'][websites_regex.match(d[1]).to_s.to_i]['tfa']
        puts 'HIT'
      end
    end
  end
  mailchimp = Mailchimp::API.new(ENV['MAILCHIMPAPIKEY'])
  weekly_email = mailchimp.campaigns.create('regular', { "list_id": 'b3fb7479bb', "subject": 'Weekly Update', from_email: 'stephen@egroat.com', from_name: 'stephen' }, html: outputs.to_s)
  mailchimp.campaigns.send(weekly_email['id'])
end
