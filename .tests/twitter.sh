#!/bin/bash

# Check Twitter handle
check_twitter () {
	handles="$(git --no-pager diff origin/master..HEAD ../_data | grep ^+[[:space:]] | grep twitter | cut -c15-)"
  if [ -z "$handles" ]; then
    echo "No Twitter handles found"
    exit 0
  else
    echo "${handles}" | while IFS= read -r handle; do
      twitter="$(ruby twitter.rb ${handle})"
      if [ "$twitter" ]; then
        echo "::error::$twitter"
        exit 1
      fi
    done
  fi
}

check_twitter

