#!/bin/bash

# Check Twitter handle
check_twitter () {
	handle="$(git --no-pager diff origin/master..HEAD ../_data | grep ^+[[:space:]] | grep twitter | cut -c15-)"
	twitter="$(ruby twitter.rb ${handle})"
	if [ "$twitter" ]; then
		echo "::error::$twitter"
		exit 1
	fi
}

check_twitter
