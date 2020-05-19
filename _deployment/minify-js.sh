#!/bin/bash
for file in js/*.js; do
  ./node_modules/.bin/babel-minify "$file" -o "$file" --simplifyComparisons --simplify --mangle
  sed -i '1s/^/---\n---\n\n/' "$file"
done
