#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

git fetch
git merge origin/master

nome="datasetDatiGovIt"

# curl -kL "https://www.dati.gov.it/api/3/action/package_list" | jq -r '.result[]' | mlr --csv --implicit-csv-header sort -f 1 then label id

URL="https://www.dati.gov.it/opendata/api/3/action/package_list"

# leggi la risposta HTTP del sito
code=$(curl -k -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kL "$URL" | jq -r '.result[]' | mlr --csv --implicit-csv-header sort -f 1 then label id >"$folder"/../../docs/"$nome"/"$nome".csv

  # scarica elenco organizzazioni
  ckanapi -r https://www.dati.gov.it/opendata/ dump organizations --all -p 4 -O "$folder"/../../docs/"$nome"/organizzazioni.jsonl

  # ordina elenco organizzazioni per name
  <"$folder"/../../docs/"$nome"/organizzazioni.jsonl jq -cs 'sort_by(.name)|.[]' >"$folder"/../../docs/"$nome"/organizzazioni.jsonl.tmp
  mv "$folder"/../../docs/"$nome"/organizzazioni.jsonl.tmp "$folder"/../../docs/"$nome"/organizzazioni.jsonl

  # estrai CSV con alcune info su organizzazioni
  <"$folder"/../../docs/"$nome"/organizzazioni.jsonl mlr --j2c cut -f name,display_name,package_count,created,id,identifier then sort -f name then put '$URL="https://dati.gov.it/view-dataset?organization=".$name' >"$folder"/../../docs/"$nome"/organizzazioni-info.csv

  # estrai soltanto nomi organizzazioni
  <"$folder"/../../docs/"$nome"/organizzazioni.jsonl mlr --j2c cut -f name then sort -f name >"$folder"/../../docs/"$nome"/organizzazioni-name.csv
fi
