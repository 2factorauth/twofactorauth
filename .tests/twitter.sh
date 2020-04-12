#!/bin/bash

# Check Twitter handle
check_twitter () {
	handles="$(git --no-pager diff origin/master..HEAD ../_data | grep ^+[[:space:]] | grep twitter | cut -c15-)"

  if [ -z "$handles" ]; then
    echo "No Twitter handles found."
    exit 0
  fi

  # Loop through all Twitter handles
  echo "${handles}" | while IFS= read -r handle; do

    twitter="$(ruby twitter.rb ${handle})"

    if [ "$twitter" ]; then
      echo "::error:: $twitter"
      exit 1
    else
      echo "Twitter handle \"${handle}\" is valid."
    fi

  done
}

check_twitter
