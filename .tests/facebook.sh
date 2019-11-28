#!/bin/bash

# Check Facebook handle
check_facebook () {
  handles="$(git --no-pager diff origin/master..HEAD ../_data | grep ^+[[:space:]] | grep facebook | cut -c16-)"
  if [ -z "$handles" ]; then
    echo "No Facebook handles found"
    exit 0
  else

    # Loop through all handles
    echo "${handles}" | while IFS= read -r handle; do

      # Get response from facebook page URL
      url="$(curl https://www.facebook.com/pg/${handle} -sSI)"

      # Trim out anything that's not a handle
      fb_handle="$(echo "${url}"| grep location | cut -c 36- | rev | cut -c 3- | rev)"

      # Compare 302 location with the handle
      if [ "$fb_handle" == "${handle}" ]; then
        echo "Checked Facebook page ${handle}"
      elif [ -z "$fb_handle" ]; then
        echo "::error:: Facebook page \"${handle}\" not found."
        exit 1
      else
        echo "::error:: Facebook handle \"${handle}\" should be \"${fb_handle}\"."
        exit 1
      fi
    done
  fi
}

check_facebook

