#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="registroComunicazioniANAC"

URL="https://dati.anticorruzione.it/data/l190-2018.json"
URLpath="https://dati.anticorruzione.it/data/l190-"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

annocorrente=$(date +"%Y")
annoprecedente=$(bc <<<"$annocorrente - 1")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  for i in $(seq 2015 "$annocorrente"); do
    curl "https://dati.anticorruzione.it/rest/legge190/meta/$i" \
      -H 'Connection: keep-alive' \
      -H 'Accept: application/json, text/plain, */*' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Referer: https://dati.anticorruzione.it/' \
      -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
      --compressed
    itemAnagrafica=$(curl 'https://dati.anticorruzione.it/rest/legge190/ricerca?max=1&start=0' -H 'Connection: keep-alive' -H 'Accept: application/json, text/plain, */*' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36' -H 'Content-Type: application/json;charset=UTF-8' -H 'Origin: https://dati.anticorruzione.it' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Dest: empty' -H 'Referer: https://dati.anticorruzione.it/' -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' --data-binary '{"anno":"'"$i"'","codiceFiscaleAmministrazione":"","denominazioneAmministrazione":"","identificativoComunicazione":""}' --compressed | jq -r '.paging.itemsCount')
    curl -kL "$URLpath$i.json" | jq -c '.[]' >"$folder"/../../docs/"$nome"/tmp.jsonl

    # se l'output ha meno di 10 righe non lo mettere in versioning
    check=$(wc <"$folder"/../../docs/"$nome"/tmp.jsonl -l)
    if [[ "$check" -gt 1000 ]]; then
      mv "$folder"/../../docs/"$nome"/tmp.jsonl "$folder"/../../docs/"$nome"/l190-"$i".jsonl
    fi

    # il dowload delle anagrafiche va paginato, quindi non come sotto
    #    curl "https://dati.anticorruzione.it/rest/legge190/ricerca?max=$itemAnagrafica&start=0" \
    #      -H 'Connection: keep-alive' \
    #      -H 'Accept: application/json, text/plain, */*' \
    #      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36' \
    #      -H 'Content-Type: application/json;charset=UTF-8' \
    #      -H 'Origin: https://dati.anticorruzione.it' \
    #      -H 'Sec-Fetch-Site: same-origin' \
    #      -H 'Sec-Fetch-Mode: cors' \
    #      -H 'Sec-Fetch-Dest: empty' \
    #      -H 'Referer: https://dati.anticorruzione.it/' \
    #      -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
    #      --data-binary '{"anno":"'"$i"'","codiceFiscaleAmministrazione":"","denominazioneAmministrazione":"","identificativoComunicazione":""}' \
    #      --compressed | jq -c '.result[]' >"$folder"/../../docs/"$nome"/tmp-anagrafica.jsonl
    #    checkAnagrafica=$(wc <"$folder"/../../docs/"$nome"/tmp-anagrafica.jsonl -l)
    #    if [[ "$checkAnagrafica" -gt 1000 ]]; then
    #      mv "$folder"/../../docs/"$nome"/tmp-anagrafica.jsonl "$folder"/../../docs/"$nome"/l190-"$i"-anagrafica.jsonl
    #    fi

  done
fi
