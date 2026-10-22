# LOG

## 2026-10-22

- `mimit-carburanti`: nuovo `storico.csv` con le medie ufficiali giornaliere dal 2023-08-01, ricostruito dalla storia git (`ricostruisci-storico.py`, data = giorno del commit) e da oggi aggiornato dallo script con la data di riferimento MIMIT (`data_fonte=mimit`). Prima la riga «Aggiornamento» veniva scartata.
- MIMIT (www.mimit.gov.it) dal 2026-10-17 accetta solo IP italiani: timeout da GitHub Actions, da VPS Hostinger (DE) e da nodi check-host in 25 paesi, risposta solo dall'Italia.
- `mimit-carburanti` e `carburanteAngragraficaStazioni` ora girano dal PC locale: task Windows `carburanti-mimit` alle 12:00 → `~/bin/carburanti-mimit-locale.sh` (clone sparse usa e getta, log in `~/.local/state/carburanti-mimit/`). Rimosso lo `schedule` dai due workflow, resta `workflow_dispatch`.
- `carburanteAngragraficaStazioni.sh` esce con errore se la sorgente non risponde 200.
- `carburanteAngragraficaStazioni`: i CSV erano vuoti dal 2026-02-10 perché MIMIT è passato dal separatore `;` a `|`; lo script ora legge `|` e i due file di uscita hanno lo stesso formato di prima (`;` e `,`).
