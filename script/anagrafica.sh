#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

<"$folder"/../risorse/list.yml yq . | mlr --j2c unsparsify >"$folder"/../docs/anagrafica.csv

# inserisci in anagrafica soltanto ciò che è pronto
mlr -I --csv filter '$ready=="true"' "$folder"/../docs/anagrafica.csv
