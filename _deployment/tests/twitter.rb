# /usr/bin/ruby
# frozen_string_literal: true

require 'twitter'

# Set auth keys
client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['twitter_consumer_key']
  config.consumer_secret = ENV['twitter_consumer_secret']
end

# Check that an argument has been sent
if ARGV.length != 1
  puts 'Error: Invalid amount of arguments passed.'
  puts 'Usage: twitter.rb handle'
  exit 1
end

begin
  # Get twitter handle of the user
  user = client.user(ARGV[0]).screen_name

# Catch any exceptions
rescue Twitter::Error => e
  if e.class == Twitter::Error::NotFound
    puts "\e[31mTwitter user #{ARGV[0]} not found.\e[39m"
    exit 2
  elsif e.class == Twitter::Error::TooManyRequests
    puts '\e[31mDisregarding Twitter checks due to too many requests.\e[39m'
    exit 0 # Soft fail if unable to access twitter api
  elsif e.class == Twitter::Error::BadRequest
    puts '\e[31mInvalid authentication. Check environment variables.\e[39m'
    exit 1
  else
    puts e.backtrace
    raise
  end
end

if user.eql? ARGV[0]
  exit 0
else
  puts "\e[31mTwitter handle \"#{ARGV[0]}\" should be \"#{user}\".\e[39m"
  exit 3
end
