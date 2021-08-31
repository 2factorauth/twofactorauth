#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
@status = 0

# Fetch created/modified files in entries/**
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def curl(url)
  puts `curl --fail -sSI -A "Mozilla/5.0 (compatible;  MSIE 7.01; Windows NT 5.0)" -H "FROM: https://2fa.directory" #{url}`
  # rubocop:disable Style/GuardClause
  unless $CHILD_STATUS.success?
    # Break build if above cURL exited with non-zero value
    puts "::error file=#{@path}:: Unable to reach #{url}"
    @status = 1
  end
  # rubocop:enable Style/GuardClause
end

diff&.each do |path|
  # Make path global for curl()
  @path = path
  entry = JSON.parse(File.read(@path)).values[0]

  # Process the url,domain & additional-domains
  curl((entry.key?('url') ? entry['url'] : "https://#{entry['domain']}/"))
  entry['additional-domains']&.each { |domain| curl("https://#{domain}/") }

  # Process documentation and recovery URLs
  curl(entry['documentation']) if entry.key?('documentation') && !entry['documentation'].start_with?('/notes/')
  curl(entry['recovery']) if entry.key? 'recovery'
end
exit(@status)
