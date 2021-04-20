#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

nome="archivioComuniANPR"

URL="https://www.anpr.interno.it/wp-content/uploads/ANPR_archivio_comuni.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/rawdata/tmp_ANPR_archivio_comuni.csv

  checkValid=$(frictionless validate --json "$folder"/rawdata/tmp_ANPR_archivio_comuni.csv | jq -r '.valid')

  if [[ "$checkValid" == "false" ]]; then
    echo "CSV non valido"
    exit
  fi

  mlr --csv sort -n ID "$folder"/rawdata/tmp_ANPR_archivio_comuni.csv >"$folder"/../../docs/"$nome"/ANPR_archivio_comuni.csv
  mlr --csv filter '$STATO=="A"' "$folder"/../../docs/"$nome"/ANPR_archivio_comuni.csv >"$folder"/../../docs/"$nome"/ANPR_archivio_comuni_attivi.csv

fi

### crea join ANPR - Comuni ISTAT ###

# converti encoding in UTF-8 del file comuni ISTAT
iconv -f Windows-1252 -t UTF-8 "$folder"/../../docs/listaComuniISTAT/Elenco-comuni-italiani.csv >"$folder"/../../docs/"$nome"/Elenco-comuni-italiani.csv

# rimuovi a capo nell'intestazione dei file ISTAT
mlr -I --csv --ifs ";" -N put -S 'if (NR == 1) {for (k in $*) {$[k] = clean_whitespace(gsub($[k], "\n"," "))}}' "$folder"/../../docs/"$nome"/Elenco-comuni-italiani.csv

# estrai colonne utili dal file ISTAT
mlr -I --csv clean-whitespace then cut -f "Codice Comune formato alfanumerico","Ripartizione geografica","Denominazione Regione","Denominazione dell'Unità territoriale sovracomunale (valida a fini statistici)","Flag Comune capoluogo di provincia/città metropolitana/libero consorzio","Codice NUTS1 2010","Codice NUTS2 2010 (3)","Codice NUTS3 2010" then rename "Codice Comune formato alfanumerico",CODISTAT "$folder"/../../docs/"$nome"/Elenco-comuni-italiani.csv

# fai JOIN tra dati ANPR e dati ISTAT
mlr --csv join --ul -j CODISTAT -f "$folder"/../../docs/"$nome"/ANPR_archivio_comuni_attivi.csv then unsparsify "$folder"/../../docs/"$nome"/Elenco-comuni-italiani.csv >"$folder"/../../docs/"$nome"/tmp.csv

# rinomina file di JOIN
mv "$folder"/../../docs/"$nome"/tmp.csv "$folder"/../../docs/"$nome"/comuniANPR_ISTAT.csv

# cancella file inutile
rm "$folder"/../../docs/"$nome"/Elenco-comuni-italiani.csv
