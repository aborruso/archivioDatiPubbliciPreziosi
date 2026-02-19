# Repository Guidelines

## Project Structure & Module Organization
This repository is a data archive with automation scripts.
- `docs/<dataset>/`: generated/public data outputs (CSV, TSV, JSONL, PDFs).
- `script/<dataset>/<dataset>.sh`: dataset-specific ETL/download pipelines.
- `script/anagrafe.sh`, `script/buildStructure.sh`, `script/webarchive*.sh`: shared maintenance utilities.
- `.github/workflows/*.yml`: scheduled jobs that run scripts and auto-commit refreshed data.
- `risorse/list.yml`: dataset registry (name, source URL, schedule, license, readiness).
- `bin/`: local helper binaries (`mlr`, `mlrgo`) used by workflows.

## Build, Test, and Development Commands
No monolithic build exists; run dataset scripts directly.
- `bash script/anagrafica.sh`: regenerate `docs/anagrafica.csv` from `risorse/list.yml`.
- `bash script/<dataset>/<dataset>.sh`: refresh one dataset (example: `bash script/datasetDatiGovIt/datasetDatiGovIt.sh`).
- `bash script/buildStructure.sh`: scaffold `docs/`, `script/`, and workflow placeholders from `risorse/list.yml`.
- `git diff -- docs/<dataset>`: inspect generated data changes before commit.

Typical CLI dependencies: `curl`, `jq`, `yq`, `mlr`, `ckanapi` (some scripts also use `ogr2ogr`, `mapshaper`, `python3`).

## Coding Style & Naming Conventions
- Use Bash for pipelines (`#!/bin/bash`) with safety flags where possible: `set -euo pipefail`.
- Keep scripts idempotent and path-safe: compute `folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.
- Preserve naming symmetry: dataset key in `risorse/list.yml` must match `script/<name>/<name>.sh` and `docs/<name>/`.
- Prefer small, composable CLI steps (`curl` -> `jq`/`mlr` -> sorted output).

## Testing Guidelines
There is no formal unit-test suite. Validate by:
- Running the target script locally.
- Verifying output files are updated only in expected paths.
- Spot-checking schema/order (headers, delimiters, encoding) with `mlr head`, `mlr check`, or `file`.

## Commit & Pull Request Guidelines
History shows many automated commits (`Data e ora aggiornamento: <ISO timestamp>`). For manual commits:
- Keep subject short, imperative, and dataset-scoped (for example: `datasetDatiGovIt: normalize organization sort`).
- Commit generated data and script changes together when they are causally linked.
- In PRs, include: data source touched, script/workflow changed, sample diff summary, and any breaking schema changes.
