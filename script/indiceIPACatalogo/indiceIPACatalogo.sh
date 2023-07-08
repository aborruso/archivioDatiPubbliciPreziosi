#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

nome="indiceIPACatalogo"

mkdir -p "$folder"/../../docs/"$nome"

# estrai URL file e nome file
yq <"$folder"/../../risorse/list.yml -r '.[] | select(.nome=="'"$nome"'").URL' | mlr --j2t cat | tail -n +2 >"$folder"/tmp.tsv

# scarica risorse
while IFS=$'\t' read -r url file; do
  echo "$file"
  curl -ksL "$url" >"$folder"/../../docs/"$nome"/"$file"
  mlr -I --csv cat "$folder"/../../docs/"$nome"/"$file"
done <"$folder"/tmp.tsv

