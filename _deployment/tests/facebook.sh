#!/bin/bash

# Check Facebook handle
check_facebook () {
  handles="$(git diff origin/master...HEAD ../../_data | grep "^+[[:space:]]*facebook:" | cut -c16-)"

  if [[ ! "$handles" =~ [^[:space:]] ]]; then
    echo "No Facebook handles found."
    exit 0
  fi

  status=0
  # Loop through all handles
  for handle in $handles; do

    # Get real handle from facebook page location URL
    fb_handle="$(curl https://www.facebook.com/pg/${handle} -sSI | sed -n '/location/s?.*com/\([^/]*\)/.*?\1?p' )"

    # Compare 302 location with the handle
    if [ "$fb_handle" == "$handle" ]; then
      echo -e "\e[32mFacebook page \"${handle}\" is valid.\e[39m"
    elif [ -z "$fb_handle" ]; then
      echo -e "\e[31mFacebook page \"${handle}\" not found.\e[39m"
      status=1
    else
      echo -e "\e[31mFacebook handle \"${handle}\" should be \"${fb_handle}\".\e[39m"
      status=1
    fi

  done

  exit $status
}

check_facebook
