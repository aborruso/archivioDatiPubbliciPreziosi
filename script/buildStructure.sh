#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

yq <"$folder"/../risorse/list.yml -r '.[].nome' | while read line; do
  # crea cartelle per dataset (in docs e script), se non esistono
  mkdir -p "$folder"/../docs/"$line"
  touch "$folder"/../docs/"$line"/.keep
  mkdir -p "$folder"/../script/"$line"
  touch "$folder"/../script/"$line"/.keep

  # crea script dataset se non esiste
  if [ ! -f "$folder"/../script/"$line"/"$line".sh ]; then
    touch "$folder"/../script/"$line"/"$line".sh
  fi

  # crea workflow dataset se non esiste e se il dataset è marcato come pronto
  if [ ! -f "$folder"/../.github/workflows/"$line".yml ] && [ $(yq <"$folder"/../risorse/list.yml '.[] | select(.nome=="'$"line"'").ready') = "true" ]; then
    touch "$folder"/../.github/workflows/"$line".yml
  fi
done
