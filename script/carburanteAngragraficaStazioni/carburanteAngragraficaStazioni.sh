#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="carburanteAngragraficaStazioni"

URL="https://www.mise.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv
  sed -i 1d "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv
  mlr -I  --csvlite --fs ";" sort -n idImpianto  "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv

fi
