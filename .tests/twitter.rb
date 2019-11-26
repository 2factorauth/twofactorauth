#/usr/bin/ruby
require 'twitter'

# Set auth keys
client = Twitter::REST::Client.new do |config|
  config.access_token        = ENV["access_key"]
  config.access_token_secret = ENV["access_secret"]
  config.consumer_key        = ENV["consumer_key"]
  config.consumer_secret     = ENV["consumer_secret"]
end

# Check that an argument has been sent
if ARGV.length != 1
	puts "Usage: twitter.rb handle"
	exit 1
end

begin

	# Get twitter handle of the user
	user = client.user(ARGV[0]).screen_name

# Catch any exceptions
rescue Exception => e
	if e.class == Twitter::Error::NotFound
		puts "Twitter user #{ARGV[0]} not found."
		exit 2
	elsif e.class == Twitter::Error::TooManyRequests 
		puts "Disregarding Twitter checks due to too many requests."
		exit 0 # Soft fail if unable to access twitter api
	else
		puts e.backtrace
		raise
	end
end

if user.eql? ARGV[0]
	exit 0
else
	puts "Twitter handle \"#{ARGV[0]}\" should be \"#{user}\"."
	exit 3
end
