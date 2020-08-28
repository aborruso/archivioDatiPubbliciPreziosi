#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="RNDTcatalogo"

URL="http://geodati.gov.it/RNDT/csw"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [[ "$code" -eq 200 ]]; then

  # scarica catalogo in formato CSV
  ogr2ogr -F CSV "$folder"/../../docs/"$nome"/RNDTcatalogo.csv "CSW:http://geodati.gov.it/RNDT/csw" -oo ELEMENTSETNAME=full -oo FULL_EXTENT_RECORDS_AS_NON_SPATIAL=YES -oo MAX_RECORDS=500 --config GML_SKIP_CORRUPTED_FEATURES YES
  # ordina catalogo per data di modifica, discendente
  mlr -I --csv sort -r modified "$folder"/../../docs/"$nome"/RNDTcatalogo.csv
  # crea file con codice IPA e conteggio risorse per codice IPA
  mlr --csv cut -f identifier then put -S '$identifier=sub($identifier,":.*","")' then count -g identifier then rename identifier,cod_amm then sort -f cod_amm then filter -S -x '$cod_amm=~"[{]"' "$folder"/../../docs/"$nome"/RNDTcatalogo.csv >"$folder"/../../docs/"$nome"/IPA.csv

fi
