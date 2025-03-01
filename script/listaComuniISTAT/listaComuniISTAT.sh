#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="listaComuniISTAT"

URL="https://www.istat.it/storage/codici-unita-amministrative/Elenco-comuni-italiani.csv"

# URL="https://www.istat.it/storage/codici-unita-amministrative/Elenco-comuni-italiani.xlsx"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  cd "$folder"/../../docs/"$nome"
  curl -skL "$URL" >Elenco-comuni-italiani.csv

  iconv -f Windows-1252 -t utf-8 Elenco-comuni-italiani.csv >tmp.csv

  mv tmp.csv Elenco-comuni-italiani.csv

  # se ci sono novità sul repo, avvisami
  if [ $(git status --porcelain | wc -l) -eq "0" ]; then
    echo "  🟢 nulla di nuovo."
  else
    echo "  🔴 occhio, ci sono degli aggiornamenti"
    #curl -X POST -H "Content-Type: application/json" -d '{"value1":"novità sul dataset dei comuni"}' https://maker.ifttt.com/trigger/alert/with/key/"$SUPER_SECRET"
  fi

fi
