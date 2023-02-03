#!/bin/bash

status=0

# $1 = directory
# $2, $3, ... = permitted file extensions
function checkExt()
{
  dir="$1"
  shift
  regex="\\.\($(echo $* | sed 's/ /\\|/g')\)$"
  if find "$dir" -type f | grep -q -v "$regex"; then
    echo "Directory '$dir' may only have files with the following extensions: $*"
    status=1
  fi
}

# $1 = directory
# $2, $3, ... = permitted file permissions
function checkPerm()
{
  dir="$1"
  shift
  unset pattern
  for p; do
    pattern+="${pattern+ -a }! -perm $p"
  done
  if find "$dir" -type f $pattern -print -quit | grep -q .; then
    echo "Directory '$dir' may only have files with the following permissions: $*"
    status=1
  fi
}

[ -e api ] && checkExt api json sig
checkExt img svg png
checkExt entries json
checkExt scripts rb
checkExt tests rb sh json
checkPerm img 664 644
checkPerm tests 775 755 664 644
checkPerm entries 664 644
checkPerm scripts 775 755
checkPerm .circleci 664 644
checkPerm .github 664 644
exit $status
