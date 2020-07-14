#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

<"$folder"/../risorse/listArchive.yml yq -r '.[].URL'>"$folder"/../risorse/listArchive.txt

rm "$folder"/webarchiveLatest.log
while read p; do
  echo "$p"
  curl -X POST -H "Accept: application/json"  -H "Authorization: LOW $SUPER_SECRET" -d 'url='"$p"'&capture_outlinks=1&capture_screenshot=1&outlinks_availability=1'  https://web.archive.org/save >>"$folder"/webarchiveLatest.log
  sleep 10;
done <"$folder"/../risorse/listArchive.txt
