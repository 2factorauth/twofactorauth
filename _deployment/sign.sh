#!/usr/bin/env bash

for file in api/v*/*.json; do
echo "$file.sig"
echo $1 | gpg --yes --passphrase --local-user $2 --output "$file.sig" --sign "$file"
done