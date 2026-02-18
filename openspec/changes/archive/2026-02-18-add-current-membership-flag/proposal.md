## Why

La tabella eventi `organizzazioni-ingresso-uscita.csv` mostra la storia di ingresso/uscita, ma manca un indicatore immediato dello stato attuale. Aggiungere una colonna `corrente` permette di distinguere subito le organizzazioni oggi presenti da quelle non piu' presenti.

## What Changes

- Estendere lo schema dell'output storico con la colonna `corrente`.
- Calcolare `corrente` confrontando ogni riga evento con l'ultima versione disponibile di `docs/datasetDatiGovIt/organizzazioni.jsonl`.
- Definire i valori ammessi: `1` se la coppia (`name`,`identifier`) e' presente nell'ultima snapshot, `0` altrimenti.
- Mantenere ordinamento stabile per minimizzare i diff.

## Capabilities

### New Capabilities
- Nessuna.

### Modified Capabilities
- `organization-membership-history`: Estende lo schema eventi con `corrente` e ne definisce la regola di calcolo sulla snapshot piu' recente.

## Impact

- Affected data: `docs/datasetDatiGovIt/organizzazioni-ingresso-uscita.csv` (nuova colonna).
- Affected implementation area: `script/datasetDatiGovIt/organizzazioniMembershipHistory.sh`.
- Dipendenze operative: parsing JSONL con `jq` e confronto con l'ultima snapshot storica del file.
