## 1. Event extraction logic

- [x] 1.1 Enumerare le revisioni di `docs/datasetDatiGovIt/organizzazioni-name.csv` con data commit in ordine cronologico.
- [x] 1.2 Calcolare differenze di membership tra revisioni consecutive e derivare eventi `ingresso`/`uscita`.
- [x] 1.3 Costruire la tabella eventi con colonne `name`, `evento`, `data` (`YYYY-MM-DD`).

## 2. Output integration

- [x] 2.1 Salvare l'output storico in un percorso `docs/datasetDatiGovIt/` coerente con gli altri artefatti.
- [x] 2.2 Aggiornare lo script `script/datasetDatiGovIt/datasetDatiGovIt.sh` (o script dedicato) per rigenerare la tabella in modo idempotente.

## 3. Validation

- [x] 3.1 Verificare su un campione di commit che ingressi/uscite coincidano con i diff Git reali.
- [x] 3.2 Validare formato data `YYYY-MM-DD` e assenza di righe duplicate evento.
- [x] 3.3 Eseguire controllo finale con `openspec validate build-organization-membership-history --strict --no-interactive`.
