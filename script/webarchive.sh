#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# se lo script è lanciato sulla mia macchina, leggi il file di config
if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/../.config
fi

yq <"$folder"/../risorse/listArchive.yml -r '.[].URL' >"$folder"/../risorse/listArchive.txt
yq <"$folder"/../risorse/listArchive.yml . | mlr --j2t cut -f URL,if_not_archived_within | tail -n +2 >"$folder"/../risorse/listArchive.tsv

rm "$folder"/webarchiveLatest.log

# verifica se ci sono elementi in processing
statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')

# finché ci sono elementi in processing aspetta
while [[ "$statusUser" -gt 0 ]]; do
  echo "wait"
  sleep 0.1
  statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
done

while IFS=$'\t' read -r url time; do
  curl -X POST -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" \
    -d "url=$url" \
    -d "capture_outlinks=1" \
    -d "capture_all=1" \
    -d "skip_first_archive=1" \
    -d "js_behavior_timeout=29" \
    -d "capture_screenshot=1" \
    -d "outlinks_availability=1" \
    -d "if_not_archived_within=$time" https://web.archive.org/save -w "\n" >>"$folder"/webarchiveLatest.log
  sleep 15
  statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
  while [[ "$statusUser" -gt 0 ]]; do
    echo "wait"
    sleep 2
    statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
  done

done <"$folder"/../risorse/listArchive.tsv

mlr --j2t unsparsify then sort-within-records "$folder"/webarchiveLatest.log >"$folder"/webarchiveLatest.tsv
