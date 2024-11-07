#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ottieni la directory in cui si trova lo script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Vai alla radice del repository
cd "${folder}"/../.. || exit

# Nome del file senza estensione
nome="omicidiVolontari"

# Crea la cartella di output
mkdir -p "${folder}"/../../docs/omicidiVolontari/archivio
mkdir -p "${folder}"/../../docs/omicidiVolontari/archivio_reshape

# Percorso del file CSV nel repository, relativo alla root del repository
file="docs/omicidiVolontari/omicidiVolontari.csv"

# Elenca tutti i commit che hanno modificato il file e ne salva la data e l'hash
git log --format="%h %ad" --date=format:"%Y%m%d" -- "$file" | while read -r commit_hash commit_date; do
  # Estrai il contenuto del file alla versione di ogni commit
  git show "${commit_hash}:${file}" >"${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}.csv"
  echo "Salvata versione del ${commit_date} come ${nome}_${commit_date}.csv"

  # rimuovi i caratteri non UTF-8
  iconv -f UTF-8 -t UTF-8 -c "${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}.csv" >"${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}_clean.csv"
  mv "${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}_clean.csv" "${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}.csv"

  # rimuovi inutili spazi bianchi
  mlr -I -S --csv clean-whitespace "${folder}/../../docs/omicidiVolontari/archivio/${nome}_${commit_date}.csv"

  # cancella file errati
  find "${folder}"/../../docs/omicidiVolontari/archivio -type f -regex '.*omicidiVolontari_202309\(08\|11\).*' -delete

done

### reshape dei dati ###

cd "${folder}"

mkdir -p "${folder}/tmp" && find "${folder}/tmp" -mindepth 1 -delete

# crea copia dei file raw
cp -r "${folder}"/../../docs/omicidiVolontari/archivio/* "${folder}"/tmp/

# correggi errore di data
sed -i -r 's/22 ottobre/5 novembre/g' "${folder}"/tmp/omicidiVolontari_20231106.csv

# per ogni file csv
find "${folder}"/tmp -type f -name "omicidiVolontari_*.csv" | while read -r file; do

  filename=$(basename "$file")

  # aggiungi data osservazione
  data=$(mlr --c2n --from "$file" put '$data=regextract_or_else($[[6]],"[0-9]+ [a-zA-Z]+ [0-9]{4}$","")' then cut -f data then head -n 1)

  # converti data in formato ISO YYYY-MM-DD
  dataiso=$(python3 -c "import locale, datetime; locale.setlocale(locale.LC_TIME, 'it_IT.utf8'); print(datetime.datetime.strptime('$data', '%d %B %Y').strftime('%Y-%m-%d'))")

  # se filename contiene "omicidiVolontari_20231106" sleep 5
  if [[ $filename == *"omicidiVolontari_20231106"* ]]; then
    sleep 0
  fi

  # aggiungi data osservazione al file
  mlr -I -S --csv --from "$file" put '$data="'"$dataiso"'"'

  # estri nome seconda colonna
  colonna_due=$(mlr --c2n --from "$file" put '$c=$[[2]]' then cut -f c then head -n 1)

  # estri nome terza colonna
  colonna_tre=$(mlr --c2n --from "$file" put '$c=$[[3]]' then cut -f c then head -n 1)

  # estri nome quarta colonna
  colonna_quattro=$(mlr --c2n --from "$file" put '$c=$[[4]]' then cut -f c then head -n 1)

  attuale=$((colonna_quattro + 1))

  # rimuovi colonna 2, 3 e 4
  mlr --csv -I -S cut -x -f "$colonna_due","$colonna_tre","$colonna_quattro" "$file"

  # rinomina le colonne
  mlr --csv -I -S label categoria,"$colonna_quattro","$attuale" then cat -n "$file"

  # passa da wide a long
  mlr -I --csv reshape -r "[0-9]" -o anno,valore "$file"

done

# unisci i file
mlr --csv unsparsify then put '$file=FILENAME;$file=sub($file,".+/","")' then sort -t anno,data,n then put '$data=sub($data,"^([0-9]{4})(.+)$",$anno."\2")' "${folder}"/tmp/*.csv >"${folder}"/../../docs/omicidiVolontari/tmp_archivio_due_anni.csv

mlr -I --csv --from "${folder}"/../../docs/omicidiVolontari/tmp_archivio_due_anni.csv put '
if ($n==1) {
  $cat_norm="omicidi"
} elif ($n==2) {
  $cat_norm="omicidi_femminili"
} elif ($n==3) {
  $cat_norm="omicidi_ambito_familiare"
} elif ($n==4) {
  $cat_norm="omicidi_ambito_familiare_femminili"
} elif ($n==5) {
  $cat_norm="omicidi_da_partner"
} elif ($n==6) {
  $cat_norm="omicidi_da_partner_femminili"
}
' then reorder -f n,categoria,cat_norm

cd "${folder}"

mkdir -p "${folder}/tmp" && find "${folder}/tmp" -mindepth 1 -delete

# crea copia dei file raw
cp -r "${folder}"/../../docs/omicidiVolontari/archivio/* "${folder}"/tmp/

# correggi errore di data
sed -i -r 's/22 ottobre/5 novembre/g' "${folder}"/tmp/omicidiVolontari_20231106.csv

# per ogni file csv
find "${folder}"/tmp -type f -name "omicidiVolontari_*.csv" | while read -r file; do

  filename=$(basename "$file")

  # aggiungi data osservazione
  data=$(mlr --c2n --from "$file" put '$data=regextract_or_else($[[6]],"[0-9]+ [a-zA-Z]+ [0-9]{4}$","")' then cut -f data then head -n 1)

  # converti data in formato ISO YYYY-MM-DD
  dataiso=$(python3 -c "import locale, datetime; locale.setlocale(locale.LC_TIME, 'it_IT.utf8'); print(datetime.datetime.strptime('$data', '%d %B %Y').strftime('%Y-%m-%d'))")

  # se filename contiene "omicidiVolontari_20231106" sleep 5
  if [[ $filename == *"omicidiVolontari_20231106"* ]]; then
    sleep 0
  fi

  # aggiungi data osservazione al file
  mlr -I -S --csv --from "$file" put '$data="'"$dataiso"'"'

  # estri nome seconda colonna
  colonna_due=$(mlr --c2n --from "$file" put '$c=$[[2]]' then cut -f c then head -n 1)

  # estri nome terza colonna
  colonna_tre=$(mlr --c2n --from "$file" put '$c=$[[3]]' then cut -f c then head -n 1)

  # estri nome quarta colonna
  colonna_quattro=$(mlr --c2n --from "$file" put '$c=$[[4]]' then cut -f c then head -n 1)

  colonna_cinque=$(mlr --c2n --from "$file" put '$c=$[[5]]' then cut -f c then head -n 1)

  attuale=$((colonna_quattro + 1))

  # rimuovi colonna 2, 3, 4 e 5
  mlr --csv -I -S cut -x -f "$colonna_due","$colonna_tre","$colonna_quattro","$colonna_cinque" "$file"

  # rinomina le colonne
  mlr --csv -I -S label categoria,"$attuale" then cat -n "$file"

  # passa da wide a long
  mlr -I --csv reshape -r "[0-9]" -o anno,valore "$file"

done

# unisci i file
mlr --csv unsparsify then put '$file=FILENAME;$file=sub($file,".+/","")' then sort -t anno,data,n then put '$data=sub($data,"^([0-9]{4})(.+)$",$anno."\2")' "${folder}"/tmp/*.csv >"${folder}"/../../docs/omicidiVolontari/tmp_archivio.csv

mlr -I --csv --from "${folder}"/../../docs/omicidiVolontari/tmp_archivio.csv put '
if ($n==1) {
  $cat_norm="omicidi"
} elif ($n==2) {
  $cat_norm="omicidi_femminili"
} elif ($n==3) {
  $cat_norm="omicidi_ambito_familiare"
} elif ($n==4) {
  $cat_norm="omicidi_ambito_familiare_femminili"
} elif ($n==5) {
  $cat_norm="omicidi_da_partner"
} elif ($n==6) {
  $cat_norm="omicidi_da_partner_femminili"
}
' then reorder -f n,categoria,cat_norm

# copia tutti i file csv da "${folder}"/tmp/ a "${folder}"/../../docs/omicidiVolontari/archivio_reshape/
cp -r "${folder}"/tmp/* "${folder}"/../../docs/omicidiVolontari/archivio_reshape/

# aggiungi categoria normalizzata
find "${folder}"/../../docs/omicidiVolontari/archivio_reshape/ -type f -name "omicidiVolontari_*.csv" | while read -r file; do

  mlr -I --csv --from "$file" put '
  if ($n==1) {
    $cat_norm="omicidi"
  } elif ($n==2) {
    $cat_norm="omicidi_femminili"
  } elif ($n==3) {
    $cat_norm="omicidi_ambito_familiare"
  } elif ($n==4) {
    $cat_norm="omicidi_ambito_familiare_femminili"
  } elif ($n==5) {
    $cat_norm="omicidi_da_partner"
  } elif ($n==6) {
    $cat_norm="omicidi_da_partner_femminili"
  }
  ' then reorder -f n,categoria,cat_norm

done
