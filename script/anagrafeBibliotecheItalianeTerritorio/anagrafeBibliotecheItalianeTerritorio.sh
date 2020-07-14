#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="anagrafeBibliotecheItalianeTerritorio"

URL="http://opendata.anagrafe.iccu.sbn.it/territorio.zip"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -skL "$URL" >"$folder"/../../docs/"$nome"/territorio.zip
  unzip "$folder"/../../docs/"$nome"/territorio.zip -d "$folder"/../../docs/"$nome"
  rm "$folder"/../../docs/"$nome"/territorio.zip
  mlr -I --csv --fs ";" sort -f codice-isil "$folder"/../../docs/"$nome"/territorio.csv
fi
