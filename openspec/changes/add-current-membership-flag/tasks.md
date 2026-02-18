## 1. Schema and logic update

- [x] 1.1 Estendere la generazione di `organizzazioni-ingresso-uscita.csv` con la colonna `corrente`.
- [x] 1.2 Derivare l'insieme corrente dalla revisione piu' recente di `docs/datasetDatiGovIt/organizzazioni.jsonl`.
- [x] 1.3 Impostare `corrente=1` per righe con coppia (`name`,`identifier`) presente nell'ultima snapshot e `0` negli altri casi.

## 2. Output consistency

- [x] 2.1 Mantenere output idempotente e ordinamento stabile per ridurre i diff.
- [x] 2.2 Rigenerare `docs/datasetDatiGovIt/organizzazioni-ingresso-uscita.csv` con il nuovo schema.

## 3. Validation

- [x] 3.1 Verificare che i soli valori di `corrente` siano `0` e `1`.
- [x] 3.2 Verificare su campione che una coppia (`name`,`identifier`) presente oggi abbia `corrente=1` e una non presente abbia `corrente=0`.
- [x] 3.3 Eseguire `openspec validate add-current-membership-flag --strict --no-interactive`.
