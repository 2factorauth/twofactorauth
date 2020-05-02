#!/bin/bash

# Check Alexa rank
check_rank () {
  urls="$(git log -p origin/master..HEAD ../_data | grep "^+[[:space:]]*url: " | cut -c11-)"

  if [ -z "$urls" ]; then
    echo "No URLs found."
    exit 0
  fi

  # Loop through all URLs
  echo "${urls}" | while IFS= read -r url; do

    # Get the domain from the URL
    domain="$(echo ${url} | cut -d'/' -f3)"

    # Get Alexa rank for the domain
    echo "$(ruby alexa.rb ${domain})"

  done
}

check_rank
