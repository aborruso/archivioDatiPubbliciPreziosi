#!/bin/bash

set -euo pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$folder/../.." && pwd)"

source_file="docs/datasetDatiGovIt/organizzazioni.jsonl"
output_file="$repo_root/docs/datasetDatiGovIt/organizzazioni-ingresso-uscita.csv"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

prev_file="$tmp_dir/prev.txt"
curr_file="$tmp_dir/curr.txt"
events_file="$tmp_dir/events.csv"
sorted_events_file="$tmp_dir/events.sorted.csv"
current_pairs_file="$tmp_dir/current-pairs.csv"
commits_file="$tmp_dir/commits.txt"

: >"$prev_file"
printf 'name,identifier,site,created,region,evento,data\n' >"$events_file"

git -C "$repo_root" log --follow --reverse --date=short --pretty=format:'%H|%ad' -- "$source_file" >"$commits_file"

if [[ ! -s "$commits_file" ]]; then
  echo "Errore: nessuna storia Git trovata per $source_file" >&2
  exit 1
fi

while IFS='|' read -r commit_hash commit_date || [[ -n "${commit_hash:-}" ]]; do
  [[ -z "${commit_hash:-}" ]] && continue
  git -C "$repo_root" show "${commit_hash}:${source_file}" \
    | jq -r '[.name, (.identifier // ""), (.site // ""), (.created // ""), (.region // "")] | @tsv' \
    | sort -u >"$curr_file"

  comm -13 "$prev_file" "$curr_file" \
    | awk -F'\t' -v data="$commit_date" 'BEGIN {OFS=","} {print "\"" $1 "\"","\"" $2 "\"","\"" $3 "\"","\"" $4 "\"","\"" $5 "\"","ingresso",data}' >>"$events_file"

  comm -23 "$prev_file" "$curr_file" \
    | awk -F'\t' -v data="$commit_date" 'BEGIN {OFS=","} {print "\"" $1 "\"","\"" $2 "\"","\"" $3 "\"","\"" $4 "\"","\"" $5 "\"","uscita",data}' >>"$events_file"

  cp "$curr_file" "$prev_file"
done <"$commits_file"

git -C "$repo_root" show "HEAD:${source_file}" \
  | jq -r '[.name, (.identifier // "")] | @csv' \
  | sort -u >"$current_pairs_file"

{
  printf 'name,identifier,site,created,region,evento,data,corrente\n'
  tail -n +2 "$events_file" \
    | awk -F',' 'NR==FNR {current[$0]=1; next} {key=$1 "," $2; flag=(key in current)?1:0; print $0 "," flag}' "$current_pairs_file" - \
    | sort -t',' -k7,7r -k1,1 -k2,2 -k6,6
} >"$sorted_events_file"

if [[ "$(wc -l <"$sorted_events_file")" -le 1 ]]; then
  echo "Errore: output storico vuoto, annullo aggiornamento di $output_file" >&2
  exit 1
fi

cp "$sorted_events_file" "$output_file"
