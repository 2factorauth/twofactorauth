#!/bin/bash
# Copyright (c) 2017, Tino Reichardt <https://github.com/mcmilk/sitemap-generator>
# Copyright (c) 2022, 2factorauth <https://github.com/2factorauth/twofactorauth>

[[ $# -ne 1 ]] && { echo "USAGE: ./sitemap.sh _site" >&2; exit 1; }

# url configuration
URL="https://2fa.directory/"

# values: always hourly daily weekly monthly yearly never
get_frequency () {
  if [ "$1" -lt 7 ]; then FREQ="daily";
  elif [ "$1" -lt 32 ]; then FREQ="weekly";
  elif [ "$1" -lt 63 ]; then FREQ="monthly";
  else FREQ="yearly";
  fi;
}

# begin new sitemap
exec 1> "${1}/sitemap.xml"

# print head
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

OPTIONS='
-prune
! -iname robots.txt
! -iname manifest.json
! -iname service-worker.js
! -iname "sitemap.*"
! -iname ".*"
! -path "./css/*"
! -path "./js/*"
! -path "./img/*"
! -path "./entries/*"
'

cd "${1}" || exit 1
eval find . -type f $OPTIONS -print0 | xargs -0 stat -c '%z%n' | \
while read -r line; do
  DATE=${line:0:10}
  FILE=${line:37}
  get_frequency $((($(date +%s) - $(date +%s -r "${FILE}")) / 86400))
  echo "<url>"
  echo " <loc>${URL}${FILE}</loc>"
  echo " <lastmod>$DATE</lastmod>"
  echo " <changefreq>$FREQ</changefreq>"
  echo "</url>"
done

# print foot
echo "</urlset>"
