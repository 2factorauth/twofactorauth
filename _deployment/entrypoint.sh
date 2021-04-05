#!/bin/sh

if [ -z ${SKIP_DOS2UNIX} ]; then
  echo "Converting scripts to Unix format:"
  dos2unix _deployment/*
fi

if [ -z ${SKIP_API} ]; then
  echo "Creating API directories:"
  mkdir -p api/v1
  mkdir -p api/v2
  mkdir -p api/v3
  echo "Generating API files:"
  ruby ./_deployment/apiv*.rb
  ruby ./_deployment/used_regions.rb > api/v2/regions.json
fi

if [ -z ${SKIP_MINIFY} ]; then
  echo "Minifying JavaScript files:"
  ./_deployment/minify-js.sh
fi

if [ -z ${SKIP_WEBP} ]; then
  echo "Generating Webp images:"
  ./_deployment/webp.sh
fi

if [ -z ${SKIP_REGIONS} ]; then
  echo "Generating regions:"
  ruby ./_deployment/regions.rb --production
fi

echo "Building site:"
bundle exec jekyll serve -H 0.0.0.0 -P 4000
