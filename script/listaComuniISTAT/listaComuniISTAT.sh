#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="listaComuniISTAT"

URL="https://www.istat.it/storage/codici-unita-amministrative/Elenco-comuni-italiani.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  cd "$folder"/../../docs/"$nome"
  curl -skL -O "$URL"

fi
