#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

find "${folder}"/../../docs/omicidiVolontari/pdf/raw -type f -name "*setti*.pdf" >"${folder}"/tmp/pdf.txt

mlr --inidx --ojsonl --from "${folder}"/tmp/pdf.txt label raw_name then put '$raw_name=sub($raw_name,".+/","")' then \
put '$name=sub($raw_name,"^(.+?)(\d+)_([a-zA-Z]+)_(\d+)\.pdf","\2_\3_\4")' >"${folder}"/tmp/pdf.jsonl

cat "${folder}"/tmp/pdf.jsonl | llm -s "sei un correttore di jsonl. Ti passo un jsonl, in cui sono state estratte date dal campo raw_name al campo name, ma alcune non sono corrette, perché non è estratta la parte finale con giorno mese anno, espresso come ad esempio 21_gennaio_2024. Non modificare nulla di raw_name, ma modifica i valor di name non coerenti con gli altri.
Una volta normalizzato aggiungi un campo data_iso con la data in formato iso8601 YYYY-MM-DD.
In output produci soltanto jsonl, senza commenti" >"${folder}"/tmp.txt

cat "${folder}"/tmp.txt | grep -P "^\{.+$" >"${folder}"/tmp/pdf.jsonl

while read -r line; do
  name=$(echo "$line" | jq -r .name)
  raw_name=$(echo "$line" | jq -r .raw_name)
  data_iso=$(echo "$line" | jq -r .data_iso)
  cp "${folder}"/../../docs/omicidiVolontari/pdf/raw/"${raw_name}" "${folder}"/../../docs/omicidiVolontari/pdf/renamed/"${data_iso}".pdf
done <"${folder}"/tmp/pdf.jsonl >"${folder}"/tmp/pdf.jsonl.tmp
