#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crea cartella per archiviare i log
mkdir -p "$folder"/../docs/webarchive

# se lo script è lanciato sulla mia macchina, leggi il file di config
if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/../.config
fi

# estrai lista di URL da archiviare in formato txt e tsv
yq <"$folder"/../risorse/listArchive.yml -r '.[].URL' >"$folder"/../risorse/listArchive.txt
yq <"$folder"/../risorse/listArchive.yml . | mlr --j2t cut -f URL,if_not_archived_within | tail -n +2 >"$folder"/../risorse/listArchive.tsv

# rimuovi file di log
if [ -f "$folder"/webarchiveLatest.log ]; then
  rm "$folder"/webarchiveLatest.log
fi

# verifica se ci sono a carico dell'utente già elementi in processing su web archive
statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')

# finché ci sono elementi in processing aspetta
while [[ "$statusUser" -gt 0 ]]; do
  echo "wait"
  sleep 2
  statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
done

# salva su archive
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

  # verifica se ci sono processi in corso a carico dell'utente, se sì non procedere
  statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
  while [[ "$statusUser" -gt 0 ]]; do
    echo "wait"
    sleep 2
    statusUser=$(curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" http://web.archive.org/save/status/user | jq -r '.processing')
  done

done <"$folder"/../risorse/listArchive.tsv

mlr --j2t unsparsify "$folder"/webarchiveLatest.log >"$folder"/../docs/webarchive/webarchiveLatest.tsv

# fai check eventuali errori restituiti da archive

sleep 30

bash "$folder"/webarchiveCheckJob.sh
