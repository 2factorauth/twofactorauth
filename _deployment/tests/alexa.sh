#!/bin/bash

# Check Alexa rank
check_rank () {
  urls="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*url:" | cut -c11-)"

  if [ -z "$urls" ]; then
    echo "No URLs found."
    exit 0
  fi

  status=0
  # Loop through all URLs
  for url in $urls; do

    # Get the domain from the URL
    domain="$(echo ${url} | cut -d'/' -f3)"

    # Get Alexa rank for the domain
    ruby alexa.rb ${domain} || status=1

  done

  return $status
}

check_rank
