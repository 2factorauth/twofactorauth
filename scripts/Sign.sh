#!/bin/bash

# Create a temporary file to track the status
STATUS_FILE=$(mktemp)
echo 0 > "$STATUS_FILE"

sign_and_verify() {
  local f="$1"
  echo "$f.sig"
  echo "$PGP_PASSWORD" | gpg --yes --passphrase --local-user "$PGP_KEY_ID" --output "$f.sig" --sign "$f"
  echo "::debug:: Signing of $f exited with status $?"
  if ! gpg --verify "$f.sig" 2>/dev/null; then
    echo "::error f=$f:: File signing failed for $f"
    echo 1 > "$STATUS_FILE"
  fi
}

for f in api/v*/*.json; do
  sign_and_verify "$f"
done

STATUS=$(cat "$STATUS_FILE")
rm "$STATUS_FILE"
exit "$STATUS"
