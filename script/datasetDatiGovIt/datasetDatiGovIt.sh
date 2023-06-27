#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="datasetDatiGovIt"

# curl -kL "https://www.dati.gov.it/api/3/action/package_list" | jq -r '.result[]' | mlr --csv --implicit-csv-header sort -f 1 then label id

URL="https://www.dati.gov.it/opendata/api/3/action/package_list"

# leggi la risposta HTTP del sito
code=$(curl -k -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kL "$URL" | jq -r '.result[]' | mlr --csv --implicit-csv-header sort -f 1 then label id >"$folder"/../../docs/"$nome"/"$nome".csv

fi
