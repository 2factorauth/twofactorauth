#!/bin/bash

# Load environment variables
source .env

sign_and_verify() {
  local f="$1"
  echo "$f.sig"
  echo "$PGP_PASSWORD" | gpg --yes --passphrase --local-user "$PGP_KEY_ID" --output "$f.sig" --sign "$f" 2>/dev/null
  gpg --verify "$f.sig" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "::error f=$f:: File signing failed"
    exit 1
  fi
}

# Iterate API files in parallel
for f in api/v*/.json; do
  sign_and_verify "$f" &
done

# Wait for all background processes to complete
wait
