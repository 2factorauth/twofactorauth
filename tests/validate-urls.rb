#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def curl(url)
  puts `curl --fail -sSI #{url}`
  # Break build if above cURL exited with non-zero value
  puts "::error file=#{@path}:: Unable to reach #{url}" unless $CHILD_STATUS.success?
end

diff.each do |path|
  # Make path global for curl()
  @path = path
  entry = JSON.parse(File.read(@path)).values[0]

  # Process the url,domain & additional-domains
  curl((entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/"))
  entry['additional-domains'].each { |domain| curl("https://#{domain}/") }

  # Process documentation and recovery URLs
  curl(entry['documentation']) if entry.key? !entry['documentation'].start_with?('/notes/')
  curl(entry['recovery']) if entry.key? 'recovery'
end
