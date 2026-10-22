# LOG

## 2026-10-22

- MIMIT (www.mimit.gov.it) dal 2026-10-17 accetta solo IP italiani: timeout da GitHub Actions, da VPS Hostinger (DE) e da nodi check-host in 25 paesi, risposta solo dall'Italia.
- `mimit-carburanti` e `carburanteAngragraficaStazioni` ora girano dal PC locale: task Windows `carburanti-mimit` alle 12:00 → `~/bin/carburanti-mimit-locale.sh` (clone sparse usa e getta, log in `~/.local/state/carburanti-mimit/`). Rimosso lo `schedule` dai due workflow, resta `workflow_dispatch`.
- `carburanteAngragraficaStazioni.sh` esce con errore se la sorgente non risponde 200.
- Da risolvere: i CSV dell'anagrafica sono vuoti dal 2026-02-10, MIMIT ha cambiato il separatore da `;` a `|`.
