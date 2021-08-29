#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'json'
diff = `git diff --name-only --diff-filter=AM origin/master...HEAD entries/`.split("\n")

def curl(url, path)
  puts `curl --fail -sSI #{url}`
  puts "::error file=#{path}:: Unable to reach #{url}" unless $CHILD_STATUS.success?
end

diff.each do |path|
  next if path.empty?

  entry = JSON.parse(File.read(path)).values[0]

  if entry.key? 'url'
    curl(entry['url'], path)
  else
    curl("https://#{entry['domain']}/", path)
    entry['additional-domains'].each { |domain| curl("https://#{domain}/", path) }
  end

  curl(entry['documentation'], path) if entry.key? !entry['documentation'].start_with?('/notes/')
  curl(entry['recovery'], path) if entry.key? 'recovery'
end
