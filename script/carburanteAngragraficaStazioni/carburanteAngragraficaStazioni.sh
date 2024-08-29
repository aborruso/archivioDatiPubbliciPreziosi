#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

git fetch
git merge origin/master

nome="carburanteAngragraficaStazioni"

URL="https://www.mise.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -skL "$URL" >"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv
  # versione cleaned
  # nota bene, vengono rimossi tutte le "
  <"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv sed -r 's/"//g' | tail -n +2 | perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' >"$folder"/tmp.csv

  # righe con più di 10 campi
  grep -n -o ";" "$folder"/tmp.csv  | sort -n | uniq -c | cut -d : -f 1 | sed -r 's/^ *//g' | mlr --nidx label conteggio,riga then filter '$conteggio>9' then cut -f riga >"$folder"/tmp-errori-separatori.txt

  # rimuovi righe con numero separatori errati
  cat "$folder"/tmp-errori-separatori.txt | while read line;do
    sed -i -e ''"$line"'d' "$folder"/tmp.csv
  done

  mlr --csv --ifs ";" clean-whitespace then sort -n idImpianto "$folder"/tmp.csv | sed 's/[^[:print:]]//g' >"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi-cleaned.csv

  <"$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv tail -n +2 | grep -vP '&#' >"$folder"/../../docs/"$nome"/tmp.csv

  # righe con più di 10 campi
  grep -n -o ";" "$folder"/../../docs/"$nome"/tmp.csv  | sort -n | uniq -c | cut -d : -f 1 | sed -r 's/^ *//g' | mlr --nidx label conteggio,riga then filter '$conteggio>9' then cut -f riga >"$folder"/tmp-errori-separatori.txt

  # rimuovi righe con numero separatori errati
  cat "$folder"/tmp-errori-separatori.txt | while read line;do
    sed -i -e ''"$line"'d' "$folder"/../../docs/"$nome"/tmp.csv
  done

  mv "$folder"/../../docs/"$nome"/tmp.csv "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv

  sed -i -r 's/; */;/g' "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv

  mlrgo -I --ragged --csvlite --fs ";" sort -n idImpianto then remove-empty-columns then cut -x -r -f "^[0-9].*" then filter -x 'is_null($Gestore) || $Latitudine!=~"^([0-9]|NULL)"' "$folder"/../../docs/"$nome"/anagrafica_impianti_attivi.csv

fi
