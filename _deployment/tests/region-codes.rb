# frozen_string_literal: true

require 'yaml'
require 'uri'
require 'net/http'
require 'json'

@list_url = 'https://pkgstore.datahub.io/core/country-list/data_json/data/8c458f2d15d9f2119654b29ede6e45b8/data_json.json'
@code_cache = '/tmp/iso-3166.txt'

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
def fetch_codes
  @codes = []
  if File.exist?(@code_cache)
    # Use foreach instead of readlines due to performance
    File.foreach(@code_cache) { |line| @codes << line.strip }
  else
    url = URI(@list_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'
    request['User-Agent'] = '2fa_org'
    response = https.request(request)

    raise("Request failed. Check URL & API key. (#{response.code})") unless response.code == '200'

    # Parse response
    body = JSON.parse(response.body)
    body.each do |v|
      @codes.push(v['Code'].downcase)
    end
    # Create cache file
    file = File.new(@code_cache, 'w')
    file.puts(@codes)
    file.close
  end
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

begin
  fetch_codes
  regions_file = '_data/regions.yml'
  regions = YAML.load_file(regions_file)
  regions.each do |region|
    raise("::error:: #{region['id']} is not a real ISO 3166-2 code.") unless @codes.include?(region['id'])
  end

  sections_file = '_data/sections.yml'
  sections = YAML.load_file(sections_file)
  sections.each do |section|
    data_file = "_data/#{section['id']}.yml"
    data = YAML.load_file(data_file)
    websites = data['websites']
    websites.each do |website|
      next if website['regions'].nil?

      website['regions'].each do |region|
        raise("#{website['name']} contains an invalid ISO-3166-2 code. (\"#{region}\")") unless @codes.include?(region)
      end
    end
  end
end
