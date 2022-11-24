#!/usr/bin ruby
# frozen_string_literal: true

require 'English'
require 'parallel'
require 'fileutils'
require 'dotenv/load'

PASSWORD = ENV['PGP_PASSWORD']
KEY_ID = ENV['PGP_KEY_ID']

Parallel.each(Dir.glob('api/v*/*.json')) do |f|
  puts "#{f}.sig"
  `echo "#{PASSWORD}" | gpg --yes --passphrase --local-user "#{KEY_ID}" --output "#{f}.sig" --sign "#{f}" 2>/dev/null`
  `gpg --verify "#{f}.sig" 2>/dev/null`
  raise("::error f=#{f}:: File signing failed") unless $CHILD_STATUS.success?
end
