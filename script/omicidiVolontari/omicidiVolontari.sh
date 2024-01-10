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

  sed -i 's|wrportal.dippp.interno.it/sites/default/files|www.interno.gov.it/sites/default/files|g' "$folder"/tmp/tmp.json

  # estrai i link ai file csv
  while read line; do
    link=$(echo "$line" | jq -r '."@href"')
    titolo=$(echo "$line" | jq -r '."@title"')
    # if "omicidi volontari"
    if [[ "$link" == *"settimana"* ]]; then
      echo "$titolo"
      echo "$link"

      if [[ "$link" == *"http"* ]]; then
        curl -kL -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$link" > "$folder"/tmp/tmp.csv
      else
        curl -kL -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$radice$link" > "$folder"/tmp/tmp.csv
      fi
      dos2unix "$folder"/tmp/tmp.csv
      cp "$folder"/tmp/tmp.csv "$folder"/tmp/tmp_raw.csv
      #<"$folder"/tmp/tmp.csv sed ':a;N;$!ba;s/\([^\r]\)\n/\1/g'
      <"$folder"/tmp/tmp.csv mlrgo --csv --ifs ";" --implicit-csv-header --ragged unsparsify then remove-empty-columns then skip-trivial-records then clean-whitespace | \
      mlrgo --csv remove-empty-columns then skip-trivial-records then clean-whitespace | \
      awk '/2022/,EOF' | \
      mlrgo --csv label categoria then ssub -f categoria "?" "..." then ssub -f categoria "..." "" > "$folder"/tmp/tmp_1.csv
      cp "$folder"/tmp/tmp_1.csv "$folder"/../../docs/"$nome"/omicidiVolontari.csv
    # if "violenza sessuale di gruppo"
    elif [[ "$titolo" == *"violenza sessuale di gruppo"* ]]; then
      echo "$titolo"
      file="violenzaSessualeDiGruppo"
      curl -kL -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' "$link" > "$folder"/tmp/"$file".csv
      mlrgo -N --csv --ifs ";" --implicit-csv-header remove-empty-columns then skip-trivial-records then clean-whitespace then filter -x 'is_null($3)' "$folder"/tmp/"$file".csv | mlrgo --csv -S label "Descrizione reato" then put 'for (k in $*) {$[k] = gsub($[k], "\.", "")}' >"$folder"/tmp/tmp.csv
      cp "$folder"/tmp/tmp.csv "$folder"/../../docs/"$nome"/"$file".csv
    fi
  done < "$folder"/tmp/tmp.json
fi

mlrgo --csv filter -x '$categoria=~"femm"' then cut -x -r -f "[a-zA-Z] +[0-9]"  then cat -n then reshape -r "[0-9]" -o k,v then sort -f n,k "$folder"/../../docs/"$nome"/omicidiVolontari.csv >"$folder"/tmp1.csv

mlrgo --csv filter '$categoria=~"femm"' then cut -x -r -f "[a-zA-Z] +[0-9]" then label c then cat -n then reshape -r "[0-9]" -o k,v then sort -f n,k then cut -x -f c then rename v,di_sesso_femminile "$folder"/../../docs/"$nome"/omicidiVolontari.csv >"$folder"/tmp2.csv

mlrgo --csv join --ul -j n,k -f "$folder"/tmp1.csv then unsparsify then rename k,anno,v,numero_vittime then cut -x -f n then sort -f anno,categoria "$folder"/tmp2.csv >"$folder"/../../docs/"$nome"/omicidiVolontari_normal.csv


