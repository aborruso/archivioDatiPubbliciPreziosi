#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

curl "http://web.archive.org/cdx/search/cdx?url=interno.gov.it/sites/default/files/*&filter=original:.*omicid.*&output=json" | jq -rc '.[]|@csv' | mlr --icsv --ojsonl cat >"${folder}"/tmp/output.jsonl

mlr --jsonl --from "${folder}"/tmp/output.jsonl filter '$statuscode==200 && $mimetype=="application/pdf" && $urlkey=~"settiman.*"' then top -g original -f timestamp >"${folder}"/tmp/output_download.jsonl

while IFS= read -r line; do
  timestamp=$(echo "$line" | jq -r '.timestamp_top')
  original_url=$(echo "$line" | jq -r '.original')
  archive_url="https://web.archive.org/web/${timestamp}/${original_url}"

  output_file="${folder}/../../docs/omicidiVolontari/pdf/raw/$(basename "$original_url")"

  # se il file non esiste scaricalo
  if [ ! -f "$output_file" ]; then
    curl -s -f -o "$output_file" "$archive_url"
  fi

done <"${folder}/tmp/output_download.jsonl"
