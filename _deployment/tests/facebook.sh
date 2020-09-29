#!/bin/bash

# Check Facebook handle
check_facebook () {
  handles="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*facebook:" | cut -c16-)"

  if [ -z "$handles" ]; then
    echo "No Facebook handles found."
    exit 0
  fi

  # Loop through all handles
  echo "${handles}" | while IFS= read -r handle; do

    # Get response from facebook page URL
    url="$(curl https://www.facebook.com/pg/${handle} -sSI)"

    # Trim out anything that's not a handle
    fb_handle="$(echo "${url}"| grep location | cut -c 36- | rev | cut -c 3- | rev)"

    # Compare 302 location with the handle
    if [ "$fb_handle" == "$handle" ]; then
      echo -e "\e[32mFacebook page \"${handle}\" is valid.\e[39m"
    elif [ -z "$fb_handle" ]; then
      echo -e "\e[31mFacebook page \"${handle}\" not found.\e[39m"
      exit 1
    else
      echo -e "\e[31mFacebook handle \"${handle}\" should be \"${fb_handle}\".\e[39m"
      exit 1
    fi

  done
}

check_facebook
