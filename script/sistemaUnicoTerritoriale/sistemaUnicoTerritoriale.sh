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
# yq <"$folder"/../../risorse/list.yml -r '.[] | select(.nome=="'"$nome"'").URL' | mlr --j2t cat | tail -n +2 >"$folder"/tmp.tsv

file="comuniSistemaUnicoTerritoriale.csv"

url="https://dait.interno.gov.it/territorio-e-autonomie-locali/sut/open-data/elenco-codici-comuni-csv.php"
response=$(curl -s "$url")

status=$(curl -s -o "$folder"/../../docs/"$nome"/raw_"$file" -w "%{http_code}" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36' "$url")

#status=$(echo "$response" | jq -r '.archived_snapshots.closest.status')
#urlArchive=$(echo "$response" | jq -r '.archived_snapshots.closest.url')

if [ "$status" == "200" ]; then
    echo "Lo stato della pagina è 200. URL: $url"
    # curl -ksL "$url" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36' >"$folder"/../../docs/"$nome"/raw_"$file"
    # se il file è quello dei comuni, cambia il separatore da ";" a "," ed estrai codice comunale istat
    if [[ $(echo "$file" | grep 'comuniSistemaUnicoTerritoriale') ]]; then
      <"$folder"/../../docs/"$nome"/raw_"$file" grep -vP '^<' | mlr --icsvlite --ocsv --ifs ";" put -S '${CODICE ISTAT}=regextract_or_else(${CODICE ISTAT},"[0-9]+","")' then clean-whitespace >"$folder"/../../docs/"$nome"/"$file"
    fi
else
    echo "Lo stato della pagina non è 200. Lo script verrà interrotto."
    exit 1
fi
