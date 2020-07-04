#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="carburantePrezzi"

URL="https://www.mise.gov.it/images/exportCSV/prezzo_alle_8.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/prezzo_alle_8.csv
  sed -i 1d "$folder"/../../docs/"$nome"/prezzo_alle_8.csv

fi
