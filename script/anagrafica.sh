#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

<"$folder"/../risorse/list.yml yq . | mlr --j2c unsparsify >"$folder"/../anagrafica.csv

cp "$folder"/../anagrafica.csv "$folder"/../docs/anagrafica.csv
