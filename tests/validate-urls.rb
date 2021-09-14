#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
require 'httpclient'
status = 0

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM entries/`.split("\n")

def curl(url)
  headers = { 'User-Agent' => 'Mozilla/5.0 (compatible;  MSIE 7.01; Windows NT 5.0)', 'FROM' => '2fa.directory' }
  req = HTTPClient.new
  req.receive_timeout = 8
  return 0 if (res = req.get(url, nil, headers, follow_redirect: true).status == 200)

  raise(nil) unless res.status.match?('/50\d/')

  puts "::warning file=#{@path}:: Unexpected response from #{url} (#{res.status})"
  0
rescue StandardError => _e
  puts "::error file=#{@path}:: Unable to reach #{url} #{res.respond_to?('status') ? res.status : nil}"
  1
end

diff&.each do |path|
  # Make path global for curl()
  @path = path
  entry = JSON.parse(File.read(@path)).values[0]

  # Process the url,domain & additional-domains
  status += curl((entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/"))
  entry['additional-domains']&.each { |domain| status += curl("https://#{domain}/") }

  # Process documentation and recovery URLs
  status += curl(entry['documentation']) if entry.key?('documentation')
  status += curl(entry['recovery']) if entry.key? 'recovery'
end
exit(status)
