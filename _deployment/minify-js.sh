#!/bin/bash
for file in _site/js/*.js; do
  ./node_modules/.bin/babel-minify "$file" -o "$file" --simplifyComparisons --simplify --mangle
  sed -i '1s/^/---\n---\n\n/' "$file"
done
