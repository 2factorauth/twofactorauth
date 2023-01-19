#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'parallel'

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

@headers = {
  'User-Agent' => "2factorauth/URLValidator (Ruby/#{RUBY_VERSION}; +https://2fa.directory/bot)",
  'From' => 'https://2fa.directory/'
}

# Check if the supplied URL works
def check_url(path, url, res = nil)
  loop do
    res = Net::HTTP.get_response(URI.parse(url))
    break unless res.is_a? Net::HTTPRedirection

    url = res['location']
  end

  puts "::warning file=#{path}:: Unexpected response from #{url} (#{res.code})" unless res.is_a? Net::HTTPSuccess
rescue StandardError => e
  puts "::warning file=#{path}:: Unable to reach #{url}"
  puts "::debug:: #{e.message}" unless e.instance_of?(TypeError)
end

Parallel.each(diff, progress: 'Validating URLs') do |path|
  entry = JSON.parse(File.read(path)).values[0]

  # Process the url,domain & additional-domains
  check_url(path, (entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/"))
  entry['additional-domains']&.each { |domain| check_url(path, "https://#{domain}/") }

  # Process documentation and recovery URLs
  check_url(path, entry['documentation']) if entry.key? 'documentation'
  check_url(path, entry['recovery']) if entry.key? 'recovery'
end
