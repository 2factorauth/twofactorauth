#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# Fetch created (but not renamed) files in entries/**
diff = `git diff --name-only --diff-filter=Ar origin/master...HEAD entries/`.split("\n")

diff&.each do |path|
  entry = JSON.parse(File.read(path)).values[0]

  puts "::notice file=#{path} title=Missing Documentation::Since there is no documentation available, please could you provide us with screenshots of the setup/login process as evidence of 2FA? Please remember to block out any personal information." unless entry['documentation']

  if (entry['tfa'].include?('custom-software') && !entry['custom-software']) || (entry['tfa'].include?('custom-hardware') && !entry['custom-hardware'])
    puts "::warning file=#{path}:: A `custom-property` tag is needed since it has been included in the `tfa` array."
  end
end
