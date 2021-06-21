#!/usr/bin/env ruby
# frozen_string_literal: true

require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token = ENV['TWITTER_ACCESS_KEY']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

status = 0
# rubocop:disable Layout/LineLength
diff = `git diff origin/master...HEAD entries/ | grep "^+[[:space:]]*\\"twitter\\":" | sed -n 's/.*"twitter"[^"]*"\\(.*\\)".*/\\1/p'`
# rubocop:enable Layout/LineLength
diff.gsub("\n", '').split('"').each do |handle|
  begin
    name = client.user(handle).screen_name
    raise("Twitter handle \"#{handle}\" should be \"#{name}\".") unless handle.eql? name
  rescue Twitter::Error => e
    raise('Twitter API keys not found or invalid.') if e.instance_of? Twitter::Error::BadRequest
    raise('Too many requests to Twitter.') if e.instance_of? Twitter::Error::TooManyRequests
    raise("Twitter handle \"#{handle}\" not found.") if e.instance_of? Twitter::Error::NotFound
  end
rescue StandardError => e
  puts "\e[31m#{e.message}\e[39m"
  status = 1
end
exit status
