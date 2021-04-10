#!/bin/sh
PATH="./node_modules/.bin:$PATH"
for file in _site/js/*.js; do
  babel-minify $file -o $file --simplifyComparisons --simplify --mangle
done
