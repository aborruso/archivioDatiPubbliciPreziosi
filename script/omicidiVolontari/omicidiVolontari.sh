#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="omicidiVolontari"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/../../docs/"$nome"

git pull

URL="https://www.interno.gov.it/it/stampa-e-comunicazione/dati-e-statistiche/omicidi-volontari-e-violenza-genere"
radice="https://www.interno.gov.it"


# leggi la risposta HTTP del sito
code=$(curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$URL" --compressed | \
  scrape -be '//a[contains(@href, ".csv")]' | xq '.html.body.a' | mlr --json unsparsify > "$folder"/tmp/tmp.json

  # estrai i link ai file csv
  while read line; do
    link=$(echo "$line" | jq -r '."@href"')
    titolo=$(echo "$line" | jq -r '."#text"')
    # if "omicidi volontari"
    if [[ "$titolo" == *"settimana"* ]]; then
      echo "$titolo"
      echo "$link"
      curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$radice$link" | \
      mlrgo --csv --ifs ";" --implicit-csv-header remove-empty-columns then skip-trivial-records then clean-whitespace | \
      mlrgo --csv remove-empty-columns then skip-trivial-records then clean-whitespace | \
      tail -n +3 | \
      mlrgo --csv label categoria then ssub -f categoria "?" "..." then ssub -f categoria "..." "" > "$folder"/tmp/tmp.csv
      cp "$folder"/tmp/tmp.csv "$folder"/../../docs/"$nome"/omicidiVolontari.csv
    # if "violenza sessuale di gruppo"
    elif [[ "$titolo" == *"violenza sessuale di gruppo"* ]]; then
      echo "$titolo"
      file="violenzaSessualeDiGruppo"
      curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$radice$link" > "$folder"/tmp/"$file".csv
      mlrgo -N --csv --ifs ";" --implicit-csv-header remove-empty-columns then skip-trivial-records then clean-whitespace then filter -x 'is_null($3)' "$folder"/tmp/"$file".csv | mlrgo --csv -S label "Descrizione reato" then put 'for (k in $*) {$[k] = gsub($[k], "\.", "")}' >"$folder"/tmp/tmp.csv
      cp "$folder"/tmp/tmp.csv "$folder"/../../docs/"$nome"/"$file".csv
    fi
  done < "$folder"/tmp/tmp.json
fi



