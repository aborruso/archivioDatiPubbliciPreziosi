#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

yq <"$folder"/../risorse/listArchive.yml -r '.[].URL' >"$folder"/../risorse/listArchive.txt
yq <"$folder"/../risorse/listArchive.yml . | mlr --j2t cut -f URL,if_not_archived_within | tail -n +2 >"$folder"/../risorse/listArchive.tsv

rm "$folder"/webarchiveLatest.log

while IFS=$'\t' read -r url time; do
  curl -X POST -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET" \
    -d "url=$url" \
    -d "capture_outlinks=1" \
    -d "capture_screenshot=1" \
    -d "outlinks_availability=1" \
    -d "if_not_archived_within=$time" https://web.archive.org/save >>"$folder"/webarchiveLatest.log
  sleep 10
done <"$folder"/../risorse/listArchive.tsv
