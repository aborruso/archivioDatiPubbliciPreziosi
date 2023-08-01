#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="mimit-carburanti"

mkdir -p "$folder"/../../docs/"$nome"

git pull

media_regionale="https://www.mimit.gov.it/images/stories/carburanti/MediaRegionaleStradale.csv"
media_autostrade="https://www.mimit.gov.it/images/stories/carburanti/MediaNazionaleAutostradale.csv"

# regionale
curl -kL "$media_regionale" >"$folder"/../../docs/"$nome"/media-regionale.csv
#aggiornamento=$(head -n 1 "$folder"/../../docs/"$nome"/media-regionale.csv | grep -oP '[0-9]{2}-[0-9]{2}-[0-9]{4}' | date +%Y-%m-%d)
<"$folder"/../../docs/"$nome"/media-regionale.csv tail -n +2 | mlr --csv --ifs ";" cat >"$folder"/tmp.csv
mv "$folder"/tmp.csv "$folder"/../../docs/"$nome"/media-regionale.csv

# autostrade
curl -kL "$media_autostrade" >"$folder"/../../docs/"$nome"/media-autostrade.csv
#aggiornamento=$(<"$folder"/../../docs/"$nome"/media-autostrade.csv head -n 1 | grep -oP '([0-9]{2})-([0-9]{2})-([0-9]{4})' | date +%Y-%m-%d)
<"$folder"/../../docs/"$nome"/media-autostrade.csv tail -n +2 | mlr --csv --ifs ";" cat >"$folder"/tmp.csv
mv "$folder"/tmp.csv "$folder"/../../docs/"$nome"/media-autostrade.csv
