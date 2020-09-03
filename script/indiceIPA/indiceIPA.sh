#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="indiceIPA"

# estrai URL file e nome file
yq <"$folder"/../../risorse/list.yml -r '.[] | select(.nome=="'"$nome"'").URL' | mlr --j2t cat | tail -n +2 >"$folder"/tmp.tsv

# scarica risorse
while IFS=$'\t' read -r url file; do
  curl "$url" >"$folder"/../../docs/"$nome"/"$file"
  mlr -I --icsvlite --ifs "\t" --otsv  sort -f cod_amm "$folder"/../../docs/"$nome"/"$file"
done <"$folder"/tmp.tsv

