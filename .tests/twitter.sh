#!/bin/bash

# Check Twitter handle
check_twitter () {
	handle="$(git --no-pager diff origin/master..HEAD ../_data | grep ^+[[:space:]] | grep twitter | cut -c15-)"
  if [ -z "$handle" ]; then
    echo "No Twitter handles found"
    exit 0
  else
    twitter="$(ruby twitter.rb ${handle})"
    if [ "$twitter" ]; then
      echo "::error::$twitter"
      exit 1
    fi
  fi
}

check_twitter
