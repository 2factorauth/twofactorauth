#!/bin/bash

# Check Twitter handle
check_twitter () {
  handles="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*twitter:" | cut -c15-)"

  if [[ ! "$handles" =~ [^[:space:]] ]]; then
    echo "No Twitter handles found."
    exit 0
  fi

  gem i twitter --no-post-install-message --no-suggestions --minimal-deps --no-verbose -N -q --silent

  res=0
  # Loop through all Twitter handles
  for handle in $handles; do

    twitter="$(ruby twitter.rb ${handle})"

    if [ "$twitter" ]; then
      echo -e "\e[31m$twitter\e[39m"
      res=1
    else
      echo -e "\e[32mTwitter handle \"${handle}\" is valid.\e[39m"
    fi

  done

  exit $res
}

check_twitter
