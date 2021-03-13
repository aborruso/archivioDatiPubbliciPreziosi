#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

# se lo script è lanciato sulla mia macchina, leggi il file di config
if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/../.config
fi

# estrai tutti i job che hanno un ID e che non sono in wait perché già catturati
mlr --t2j filter -S '$job_id=~".+" && $message!=~"The same.+"' "$folder"/../docs/webarchive/webarchiveLatest.tsv >"$folder"/rawdata/webarchiveCheckID.log

if [ -f "$folder"/rawdata/tmp.log ]; then
  rm "$folder"/rawdata/tmp.log
fi

while read p; do
  #<"$p" jq -r '.url'
  job_id=$(echo "$p" | jq -r '.job_id')
  curl -X GET -H "Accept: application/json" -H "Authorization: LOW $SUPER_SECRET_WEBARCHIVE" "https://web.archive.org/save/status/$job_id" -w "\n" >>"$folder"/rawdata/tmp.log
done <"$folder"/rawdata/webarchiveCheckID.log

mlr -I --json sort-within-records "$folder"/rawdata/tmp.log

mlr --j2t filter -S '$status=="error"' then cut -r -x -f ":" "$folder"/rawdata/tmp.log >"$folder"/rawdata/tmp_errori_id.tsv

mlr --t2c join --ul -j job_id -f "$folder"/rawdata/tmp_errori_id.tsv then unsparsify "$folder"/../docs/webarchive/webarchiveLatest.tsv >"$folder"/../docs/webarchive/webarchiveJobReport.csv
