#!/bin/sh
for version in 1 2 3; do
    mkdir -p api/v$version
    scripts/APIv${version}.rb
done
