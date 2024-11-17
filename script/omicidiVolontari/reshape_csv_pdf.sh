#!/bin/bash

#set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp/reshape_csv_pdf
mkdir -p "${folder}"/risorse
mkdir -p "${folder}"/../../docs/omicidiVolontari/pdf/export

find ./tmp/reshape_csv_pdf -type f -name "*.csv" -delete

# da tutti i file csv estratti dai PDF, con l'esclusione di quelli che hanno data 2023-12-31 e 2022-01-03 che non sono settimanali
find "${folder}"/../../docs/omicidiVolontari/pdf/csv -type f -name "*.csv" | grep -v -P "(2023-12-31|2022-01-03)" | while read -r file; do

  name=$(basename "${file}" .csv)

  # rimuovi i caratteri non UTF-8
  iconv -f UTF-8 -t UTF-8 -c "${file}" >"${folder}"/tmp/reshape_csv_pdf/tmp.csv
  mv "${folder}"/tmp/reshape_csv_pdf/tmp.csv "${folder}"/tmp/reshape_csv_pdf/"${name}".csv

  # rinonimina la prima colonna e aggiungi la colonna n, in modo da avere un indice per ogni riga per ogni file
  mlr --csv label categoria then cat -n "${file}" >"${folder}"/tmp/reshape_csv_pdf/"${name}".csv

  # estrai il nome dell'ultima colonna, che contiene nel nome la data di aggiornamento
  last_field=$(mlr --c2n --from "${file}" head -n 1 then put -q '@ultimo=$[[-1]];emit @ultimo')

  # estrai soltanto i campi n, categoria e l'ultimo campo
  mlr -I --csv --from "${folder}"/tmp/reshape_csv_pdf/"${name}".csv cut -f n,categoria,"${last_field}"

  # estrai la data di aggiornamento dal nome dell'ultima colonna
  data=$(mlr --c2n --from "${folder}"/tmp/reshape_csv_pdf/"${name}".csv put '$data=regextract_or_else($[[-1]],"[0-9]+ *[a-zA-Z]+ *[0-9]{4}$","");$data=sub($data,"([0-9]+) *([a-zA-Z]+) *([0-9]{4})","\1 \2 \3")' then cut -f data then head -n 1)

  # se la data è nel formato 01 gennaio 2023
  if echo "$data" | grep -q -E "([0-9]+) ([a-zA-Z]+) ([0-9]{4})"; then

    # estrai data in formato ISO YYYY-MM-DD
    dataiso=$(python3 -c "import locale, datetime; locale.setlocale(locale.LC_TIME, 'it_IT.utf8'); print(datetime.datetime.strptime('$data', '%d %B %Y').strftime('%Y-%m-%d'))")

    # aggiungi la data in formato ISO alla colonna data e rinomina la colonna con i valori in valore
    mlr -I --csv --from "${folder}"/tmp/reshape_csv_pdf/"${name}".csv label n,categoria,valore then put '$data="'"$dataiso"'"'

  else
    sleep 0
  fi

  # se il file ha nome 2023-06-05, aggiungi come data il valore 2023-06-04, che non era presente nel nome della colonna
  if [[ $name == "2023-06-05" ]]; then
    mlr -I --csv --from "${folder}"/tmp/reshape_csv_pdf/"${name}".csv put '$data="2023-06-04"' then label n,categoria,valore
  fi

done

# unisci tutti i file csv in un unico file csv
mlr --csv unsparsify then put '$f=FILENAME;$f=sub($f,"^.+/","")' then sort -t f,n "${folder}"/tmp/reshape_csv_pdf/*.csv >"${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv

# fai un po' di pulizia nella colonna categoria
mlr -I --csv --from "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv \
  put '$categoria=gsub($categoria,"(\(|\)|\[)"," ")' then \
  put '$categoria=gsub($categoria,"^ *\.+","")' then \
  put '$categoria=gsub($categoria,"…"," ")' then \
  put '$categoria=gsub($categoria,"are */ *aff","are/aff")' then \
  clean-whitespace

# a partire dai valori scritti nella colonna categoria, crea un file jsonline che contiene la categoria e il testo corretto
#mlr --c2n cut -f categoria then uniq -a "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv | llm -s "sei un sistema di correzione di testi, che aggiunge spazi quando servono e prende la riga originale la associa alla proprietà raw e la mette in un jsonline e aggiunge la proprietà correct, con il testo corretto. Sei una cli, dammi soltanto stdout senza commenti di alcun tipo. In output un jsonline non un json" >"${folder}"/risorse/categories.jsonl

# converti il file jsonline in un file csv
mlr --ijsonl --ocsv label categoria "${folder}"/risorse/categories.jsonl >"${folder}"/risorse/categories.csv

# aggiungi i nomi corretti del campo categoria al file csv
mlr --csv join --ul -j categoria -f "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv then unsparsify then sort -t f,n then cut -x -f categoria then reorder -f n,correct then label n,categoria then rename f,file "${folder}"/risorse/categories.csv >"${folder}"/tmp/omicidiVolontari.csv

# rinomina il file
mv "${folder}"/tmp/omicidiVolontari.csv "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv

mlr -I --csv --from "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv put '
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
  ' then reorder -f n,categoria,cat_norm,data,valore,file then sort -t data,n

# aggiungi il valore mancante per il 2023-06-05, perché l'OCR non ha riconosciuto il valore
mlr -I --csv --from "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv put 'if($n==4 && $file=="2023-06-05.csv"){$valore=41}else{$valore=$valore};$anno=sub($data,"([0-9]{4})-([0-9]{2})-([0-9]{2})","\1")' then sort -t data,n then reorder -e -f anno,valore,file

for i in 2021 2022 2023; do
  echo "Anno: $i"
  mlr --csv --from "${folder}"/../../docs/omicidiVolontari/pdf/export/omicidiVolontari.csv filter '$data=~"'"^$i"'"' then step -a delta -f valore -g cat_norm >"${folder}"/../../docs/omicidiVolontari/pdf/export/"$i"_omicidiVolontari.csv

  mlr -I --csv put 'if (NR<=6 && $valore_delta==0){$valore_delta=$valore}else{$valore_delta=$valore_delta}' "${folder}"/../../docs/omicidiVolontari/pdf/export/"$i"_omicidiVolontari.csv
done
