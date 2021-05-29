#!/usr/bin/env bash

for file in api/v*/*.json; do
echo "$file.sig"
echo "$1" | gpg --yes --passphrase --local-user "$2" --output "$file.sig" --sign "$file" 2>/dev/null
gpg --verify "$file.sig" 2>/dev/null
[[ $? -eq 0 ]] || { exit 1; }
done
