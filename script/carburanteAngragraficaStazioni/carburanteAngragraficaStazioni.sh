#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="carburanteAngragraficaStazioni"

URL="https://www.mise.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv
  # versione cleaned
  # nota bene, vengono rimossi tutte le "
  <"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv sed -r 's/"//g' | tail -n +2 | perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' | mlr --csv --ifs ";" clean-whitespace then sort -n idImpianto >"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi-cleaned.csv

  <"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv tail -n +2 | grep -vP '&#' >"$folder"/../../docs/"$nome"/tmp.csv
  mv "$folder"/../../docs/"$nome"/tmp.csv "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv
  mlr -I  --csvlite --fs ";" sort -n idImpianto  "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv

fi
