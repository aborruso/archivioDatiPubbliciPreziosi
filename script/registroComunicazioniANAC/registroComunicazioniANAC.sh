#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="registroComunicazioniANAC"

URL="https://dati.anticorruzione.it/data/l190-2018.json"
URLpath="https://dati.anticorruzione.it/data/l190-"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

annocorrente=$(date +"%Y")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  for i in $(seq 2015 "$annocorrente"); do
    curl -skL "$URLpath$i.json" | jq -c '.[]' >"$folder"/../../docs/"$nome"/l190-"$i".jsonl
  done
fi
