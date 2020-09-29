#!/bin/bash
dir=$1
ext=$2
cmd=`ls $dir | grep -v "\.${ext}$"`
for file in $cmd; do
  echo "$dir/${file} doesn't contain the correct file extension for its directory."
done
exit ${#cmd}
