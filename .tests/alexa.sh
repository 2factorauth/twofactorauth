#!/bin/bash

export LC_NUMERIC=en_US.UTF-8
format_number () {
  numfmt --grouping "$@"
}

# Max allowed Alexa ranking
max_ranking=200000

formated_max_ranking="$(format_number ${max_ranking})"

# Check Alexa rank
check_rank () {
  urls="$(git --no-pager diff origin/master..HEAD ../_data| grep ^+[[:space:]] | grep url | cut -c11-)"

  if [ -z "$urls" ]; then
    echo "No URLs found."
    exit 0
  fi

  # Loop through all URLs
  echo "${urls}" | while IFS= read -r url; do

    # Get the domain from the URL
    domain="$(echo ${url} | cut -d'/' -f3)"

    # Get Alexa rank for the domain
    alexa_rank="$(ruby alexa.rb ${domain})"

    # Format ranking with thousands separator
    formated_rank="$(format_number ${alexa_rank})"

    # Check if the site is unranked
    if [ -z "$alexa_rank" ]; then
      echo "::error:: ${domain} doesn't have an Alexa rank."
      exit 1
    fi

    # Check if the rank is at or below 200K
    if [ "$alexa_rank" -gt "$max_ranking" ]; then
      echo "::error:: ${domain} has an Alexa ranking above ${formated_max_ranking}. (${formated_rank})"
      exit 1
    else
      echo "${domain} has an Alexa ranking of ${formated_rank}."
    fi

  done
}

check_rank
