#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
require 'httpclient'
status = 0

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def new_http_client
  agent_name = 'Mozilla/5.0 (compatible;  MSIE 7.01; Windows NT 5.0)'
  from = '2fa.directory'
  client = HTTPClient.new(nil, agent_name, from)
  client.ssl_config.set_default_paths # ignore built-in CA and use system defaults
  client.receive_timeout = 8
  client
end

def curl(url)
  res = new_http_client.get(url, nil, follow_redirect: true)
  return if res.status == 200
  raise(nil) unless res.status.to_s.match(/50\d|403/)

  puts "::warning file=#{@path}:: Unexpected response from #{url} (#{res.status})"
rescue StandardError => _e
  puts "::error file=#{@path}:: Unable to reach #{url} #{res.respond_to?('status') ? res.status : nil}"
  1
end

diff&.each do |path|
  # Make path global for curl()
  @path = path
  entry = JSON.parse(File.read(@path)).values[0]

  # Process the url,domain & additional-domains
  status += curl((entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/")).to_i
  entry['additional-domains']&.each { |domain| status += curl("https://#{domain}/").to_i }

  # Process documentation and recovery URLs
  status += curl(entry['documentation']).to_i if entry.key? 'documentation'
  status += curl(entry['recovery']).to_i if entry.key? 'recovery'
end
exit(status)
