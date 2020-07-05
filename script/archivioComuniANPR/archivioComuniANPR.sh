#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="archivioComuniANPR"

URL="https://www.anpr.interno.it/portale/documents/20182/50186/ANPR_archivio_comuni.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/ANPR_archivio_comuni.csv

fi
