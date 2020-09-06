#!/bin/bash

# Check Twitter handle
check_twitter () {
  handles="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*twitter:" | cut -c15-)"

  if [ -z "$handles" ]; then
    echo "No Twitter handles found."
    exit 0
  fi

  gem i twitter --no-post-install-message --no-suggestions --minimal-deps --no-verbose -N -q --silent

  # Loop through all Twitter handles
  echo "${handles}" | while IFS= read -r handle; do

    twitter="$(ruby twitter.rb ${handle})"

    if [ "$twitter" ]; then
      echo -e "\e[31m$twitter\e[39m"
      exit 1
    else
      echo -e "\e[32mTwitter handle \"${handle}\" is valid.\e[39m"
    fi

  done
}

check_twitter
