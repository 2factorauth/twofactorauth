#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
require 'httpclient'
status = 0

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def curl(url)
  headers = { 'User-Agent' => 'Mozilla/5.0 (compatible;  MSIE 7.01; Windows NT 5.0)', 'FROM' => '2fa.directory' }
  req = HTTPClient.new
  # ignore built-in CA and use system defaults
  req.ssl_config.set_default_paths
  req.receive_timeout = 8
  res = req.get(url, nil, headers, follow_redirect: true)
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
