#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="ANPRdatiMigrazione"

URL="https://dashboard.anpr.it/api/dashboard/data.json"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/"$nome".geojson
  mapshaper "$folder"/../../docs/"$nome"/"$nome".geojson -o "$folder"/../../docs/"$nome"/"$nome".csv
  mlr -I --csv sort -f label "$folder"/../../docs/"$nome"/"$nome".csv

fi

URLsubentrati="https://www.anpr.interno.it/portale/documents/20182/241820/Comuni+subentrati.xlsx"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URLsubentrati" >"$folder"/../../docs/"$nome"/"$nome"_subentrati.xlsx
  in2csv -I "$folder"/../../docs/"$nome"/"$nome"_subentrati.xlsx | mlr --csv remove-empty-columns then filter -S '${Codice Istat}=~".+"' >"$folder"/../../docs/"$nome"/"$nome"_subentrati.csv

fi

# estrai dati aggregati
<"$folder"/../../docs/"$nome"/"$nome".geojson jq '.aggregates.aggr_by_provinces' | mlr --j2c unsparsify then sort -f provincia >"$folder"/../../docs/"$nome"/aggr_by_provinces.csv
<"$folder"/../../docs/"$nome"/"$nome".geojson jq '.aggregates.aggr_by_regions' | mlr --j2c unsparsify then sort -f  regione>"$folder"/../../docs/"$nome"/aggr_by_regions.csv
