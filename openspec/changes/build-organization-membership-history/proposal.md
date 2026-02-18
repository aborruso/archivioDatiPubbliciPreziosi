## Why

`docs/datasetDatiGovIt/organizzazioni.jsonl` e' versionato e contiene l'evoluzione nel tempo delle organizzazioni, ma oggi non esiste un output esplicito che renda leggibili ingressi e uscite con i metadati chiave. Serve una tabella storica derivata dal log Git per analisi temporali e audit.

## What Changes

- Definire un nuovo output tabellare di cronologia con eventi di presenza per organizzazione.
- Tracciare, per ogni organizzazione, eventi di `ingresso` e `uscita` basati sulle differenze tra revisioni consecutive di `organizzazioni.jsonl`.
- Includere nel record evento anche `identifier`, `site` e `created` oltre a `name`.
- Normalizzare tutte le date evento in formato `YYYY-MM-DD`.
- Documentare il comportamento atteso per casi di ri-ingresso (piu' eventi per la stessa organizzazione).

## Capabilities

### New Capabilities
- `organization-membership-history`: Produce una cronologia eventi (`ingresso`/`uscita`) per ogni organizzazione usando la storia Git di `docs/datasetDatiGovIt/organizzazioni.jsonl`, includendo `name`, `identifier`, `site`, `created`.

### Modified Capabilities
- Nessuna.

## Impact

- Affected data: nuovo artefatto tabellare storico per `datasetDatiGovIt`.
- Affected implementation area: pipeline/script del dataset `datasetDatiGovIt` per il calcolo diff tra commit successivi.
- Dipendenze operative: `git` locale disponibile durante l'esecuzione della pipeline.
