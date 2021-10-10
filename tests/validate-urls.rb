#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
require 'httpclient'
require 'uri'

# Exit code
status = 0

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def redirection
  lambda { |uri, res|
    uri = URI.parse(uri)
    location = res.header['location'][0]
    "#{location.match?(%r{https?://.*}) ? nil : "#{uri.scheme}://#{uri.host}"}#{location}"
  }
end

def http_client
  agent_name = '2FactorAuth/URLValidator ' \
  "(HTTPClient/#{Gem.loaded_specs['httpclient'].version} on Ruby/#{RUBY_VERSION}; +https://2fa.directory/bot)"
  from = '2fa.directory'
  client = HTTPClient.new(nil, agent_name, from)
  client.ssl_config.set_default_paths # ignore built-in CA and use system defaults
  client.receive_timeout = 8
  client.redirect_uri_callback = redirection
  client
end

# Check if the url supplied works
def check_url(path, url)
  res = http_client.get(url, follow_redirect: true)
  return if res.status == 200
  raise(nil) unless res.status.to_s.match(/50\d|403/)

  puts "::warning file=#{path}:: Unexpected response from #{url} (#{res.status})"
rescue StandardError => e
  puts "::error file=#{path}:: Unable to reach #{url} #{res.respond_to?('status') ? res.status : nil}"
  puts e.full_message unless e.instance_of?(TypeError)
  1
end

diff&.each do |path|
  entry = JSON.parse(File.read(path)).values[0]

  # Process the url,domain & additional-domains
  status += check_url(path, (entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/")).to_i
  entry['additional-domains']&.each { |domain| status += check_url(path, "https://#{domain}/").to_i }

  # Process documentation and recovery URLs
  status += check_url(path, entry['documentation']).to_i if entry.key? 'documentation'
  status += check_url(path, entry['recovery']).to_i if entry.key? 'recovery'
end
exit(status)
