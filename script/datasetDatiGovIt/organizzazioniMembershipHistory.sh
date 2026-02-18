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

: >"$prev_file"
printf 'name,identifier,site,created,evento,data\n' >"$events_file"

while IFS='|' read -r commit_hash commit_date; do
  git -C "$repo_root" show "${commit_hash}:${source_file}" \
    | jq -r '[.name, (.identifier // ""), (.site // ""), (.created // "")] | @tsv' \
    | sort -u >"$curr_file"

  comm -13 "$prev_file" "$curr_file" \
    | awk -F'\t' -v data="$commit_date" 'BEGIN {OFS=","} {print "\"" $1 "\"","\"" $2 "\"","\"" $3 "\"","\"" $4 "\"","ingresso",data}' >>"$events_file"

  comm -23 "$prev_file" "$curr_file" \
    | awk -F'\t' -v data="$commit_date" 'BEGIN {OFS=","} {print "\"" $1 "\"","\"" $2 "\"","\"" $3 "\"","\"" $4 "\"","uscita",data}' >>"$events_file"

  cp "$curr_file" "$prev_file"
done < <(git -C "$repo_root" log --follow --reverse --date=short --pretty=format:'%H|%ad' -- "$source_file")

git -C "$repo_root" show "HEAD:${source_file}" \
  | jq -r '[.name, (.identifier // "")] | @csv' \
  | sort -u >"$current_pairs_file"

{
  printf 'name,identifier,site,created,evento,data,corrente\n'
  tail -n +2 "$events_file" \
    | awk -F',' 'NR==FNR {current[$0]=1; next} {key=$1 "," $2; flag=(key in current)?1:0; print $0 "," flag}' "$current_pairs_file" - \
    | sort -t',' -k6,6r -k1,1 -k2,2 -k5,5
} >"$sorted_events_file"

cp "$sorted_events_file" "$output_file"
