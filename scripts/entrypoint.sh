#!/bin/sh
cd /twofactorauth

if [ -z "${SKIP_DOS2UNIX}" ]; then
  echo "Converting scripts to Unix format:"
  dos2unix scripts/*
  dos2unix tests/*
fi

if [ -z "${SKIP_API}" ]; then
  echo "Creating API directories:"
  mkdir -p api/v1
  mkdir -p api/v2
  mkdir -p api/v3
  echo "Generating API files:"
  for script in ./scripts/APIv*.rb; do
    ruby "$script"
  done
fi

if [ -z "${SKIP_BUILD}" ]; then
  echo "Building site:"
  ruby ./scripts/join-entries.rb > _data/all.json
  bundle exec jekyll build
  if [ -z "${SKIP_REGIONS}" ]; then
    echo "Generating regions:"
    ruby ./scripts/regions.rb
  fi
fi

if [ -z "${SKIP_MINIFY}" ]; then
  echo "Minifying JavaScript files:"
  ./scripts/minify-js.sh
fi

bundle exec jekyll serve --skip-initial-build --host=0.0.0.0
