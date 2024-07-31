#!/bin/bash

status=0

# Expected files in directories
declare -A expected_files
expected_files[api/v3]="all.json all.json.sig call.json call.json.sig custom-hardware.json custom-hardware.json.sig custom-software.json custom-software.json.sig email.json email.json.sig regions.json regions.json.sig sms.json sms.json.sig tfa.json tfa.json.sig totp.json totp.json.sig u2f.json u2f.json.sig"
expected_files[api/v4]="all.json all.json.sig call.json call.json.sig custom-hardware.json custom-hardware.json.sig custom-software.json custom-software.json.sig email.json email.json.sig sms.json sms.json.sig totp.json totp.json.sig u2f.json u2f.json.sig"

# $1 = directory
# $2 = expected files (space-separated)
function checkFiles(){
  dir="$1";
  shift;
  missing_files=();
  for file in "$@"; do
    [[ ! -f "${dir}/${file}" ]] && missing_files+=("$file");
  done;
  if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo "Directory '$dir' is missing the following files: ${missing_files[*]}"
    status=1
  fi
}

# Validate expected files in directories
for dir in "${!expected_files[@]}"; do
  checkFiles "$dir" ${expected_files[$dir]}
done

exit $status
