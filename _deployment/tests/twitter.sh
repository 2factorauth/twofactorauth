#!/bin/bash

# Check Twitter handle
check_twitter () {
  handles="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*twitter:" | cut -c15-)"

  if [ -z "$handles" ]; then
    echo "No Twitter handles found."
    exit 0
  fi

  gem i twitter --no-post-install-message --no-suggestions --minimal-deps --no-verbose -N -q

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
