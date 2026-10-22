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
curl -kL --retry 3 --retry-delay 30 --retry-all-errors --connect-timeout 60 --max-time 180 "$media_regionale" >"$folder"/../../docs/"$nome"/media-regionale.csv
# data di riferimento dalla prima riga, "Aggiornamento GG-MM-AAAA", in AAAA-MM-GG
data_regionale=$(head -n 1 "$folder"/../../docs/"$nome"/media-regionale.csv | grep -oE '[0-9]{2}-[0-9]{2}-[0-9]{4}' | awk -F- '{print $3"-"$2"-"$1}')
<"$folder"/../../docs/"$nome"/media-regionale.csv tail -n +2 | mlr --csv --ifs ";" cat >"$folder"/tmp.csv
mv "$folder"/tmp.csv "$folder"/../../docs/"$nome"/media-regionale.csv

# autostrade
curl -kL --retry 3 --retry-delay 30 --retry-all-errors --connect-timeout 60 --max-time 180 "$media_autostrade" >"$folder"/../../docs/"$nome"/media-autostrade.csv
data_autostrade=$(head -n 1 "$folder"/../../docs/"$nome"/media-autostrade.csv | grep -oE '[0-9]{2}-[0-9]{2}-[0-9]{4}' | awk -F- '{print $3"-"$2"-"$1}')
<"$folder"/../../docs/"$nome"/media-autostrade.csv tail -n +2 | mlr --csv --ifs ";" cat >"$folder"/tmp.csv
mv "$folder"/tmp.csv "$folder"/../../docs/"$nome"/media-autostrade.csv

# storico: si sostituiscono le righe delle due date appena lette, così un secondo lancio nello stesso giorno non duplica
storico="$folder"/../../docs/"$nome"/storico.csv
campi="data,ambito,area,carburante,erogazione,prezzo,data_fonte"

mlr --csv rename REGIONE,area,TIPOLOGIA,carburante,EROGAZIONE,erogazione,"PREZZO MEDIO",prezzo \
  then put -s data="$data_regionale" '$data=@data; $ambito="stradale"; $data_fonte="mimit"' \
  then reorder -f "$campi" "$folder"/../../docs/"$nome"/media-regionale.csv >"$folder"/tmp-regionale.csv

mlr --csv cut -x -f TIPO then rename TIPOLOGIA,carburante,EROGAZIONE,erogazione,"PREZZO MEDIO",prezzo \
  then put -s data="$data_autostrade" '$data=@data; $ambito="autostradale"; $area="Italia"; $data_fonte="mimit"' \
  then reorder -f "$campi" "$folder"/../../docs/"$nome"/media-autostrade.csv >"$folder"/tmp-autostrade.csv

mlr --csv filter -s r="$data_regionale" -s a="$data_autostrade" '!(($ambito == "stradale" && $data == @r) || ($ambito == "autostradale" && $data == @a))' "$storico" >"$folder"/tmp-storico.csv

mlr --csv sort -f data,ambito,area,carburante,erogazione "$folder"/tmp-storico.csv "$folder"/tmp-regionale.csv "$folder"/tmp-autostrade.csv >"$storico"

rm "$folder"/tmp-regionale.csv "$folder"/tmp-autostrade.csv "$folder"/tmp-storico.csv
