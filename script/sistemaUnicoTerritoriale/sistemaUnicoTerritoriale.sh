#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="sistemaUnicoTerritoriale"

mkdir -p "$folder"/../../docs/"$nome"

# estrai URL file e nome file
yq <"$folder"/../../risorse/list.yml -r '.[] | select(.nome=="'"$nome"'").URL' | mlr --j2t cat | tail -n +2 >"$folder"/tmp.tsv

# scarica risorse
while IFS=$'\t' read -r url file; do
  curl -ksL "$url" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'  >"$folder"/../../docs/"$nome"/raw_"$file"
  mlr  --icsvlite --ocsv --ifs ";" put -S '${CODICE ISTAT}=regextract_or_else(${CODICE ISTAT},"[0-9]+","")' "$folder"/../../docs/"$nome"/raw_"$file" >"$folder"/../../docs/"$nome"/"$file"
done <"$folder"/tmp.tsv

