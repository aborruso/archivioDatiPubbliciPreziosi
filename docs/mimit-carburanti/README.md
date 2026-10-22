# Prezzi medi dei carburanti MIMIT

## Indice

- File
- Storico: schema
- Da dove viene la data
- Limiti e anomalie note
- Aggiornamento

## File

- `media-regionale.csv`: prezzi medi del giorno per regione e provincia autonoma, rete stradale ([fonte](https://www.mimit.gov.it/it/prezzo-medio-carburanti/regioni)).
- `media-autostrade.csv`: prezzo medio nazionale del giorno sulla rete autostradale.
- `storico.csv`: tutte le giornate dal 2023-08-01, una riga per giorno, ambito, area e carburante. MIMIT pubblica solo il dato del giorno corrente: la serie si ricostruisce dalle versioni archiviate in questo repository.

I prezzi medi sono quelli ufficiali pubblicati da MIMIT ai sensi del decreto 31 marzo 2023: media aritmetica, non pesata per l'erogato, dei prezzi in vigore alle 08:00 e comunicati da non più di otto giorni. Benzina e gasolio in modalità self, GPL e metano servito. Licenza IODL 2.0.

## Storico: schema

| campo | contenuto |
| --- | --- |
| `data` | giorno di riferimento, `AAAA-MM-GG` |
| `ambito` | `stradale` (medie regionali) o `autostradale` (media nazionale) |
| `area` | regione o provincia autonoma; `Italia` per l'ambito autostradale |
| `carburante` | `Benzina`, `Gasolio`, `GPL`, `Metano` |
| `erogazione` | `SELF` o `SERVITO` |
| `prezzo` | euro per litro (per chilo il metano), come pubblicato |
| `data_fonte` | `mimit` se la data viene dal file MIMIT, `commit` se è ricostruita |

## Da dove viene la data

Ogni file MIMIT apre con la riga `Aggiornamento GG-MM-AAAA`. Fino al 2026-10-22 lo script la scartava, quindi per le righe precedenti la data è il giorno del commit che ha archiviato il file (ora di Roma), e `data_fonte` vale `commit`. I commit sono uno al giorno e tutti successivi alle 08:30, ora in cui MIMIT pubblica i dati del giorno. Lo storico è stato ricostruito con `script/mimit-carburanti/ricostruisci-storico.py`.

## Limiti e anomalie note

- Fra il 2023-08-01 e il 2026-10-22 (1.179 giorni) mancano 39 giornate di dati stradali e 97 di dati autostradali: i giorni in cui lo scarico non è riuscito o il file non è cambiato.
- I prezzi non sono corretti: restano come pubblicati, outlier compresi. Per esempio la media del gasolio in Abruzzo il 2026-03-10 vale 5,788 e in Campania il 2026-03-11 vale 3,348; il giorno prima e quello dopo sono intorno a 2,0. Basta un impianto che comunica un prezzo errato per spostare una media aritmetica.
- Il 2024-07-02 e il 2024-07-03 MIMIT ha pubblicato, oltre a Bolzano e Trento, una voce `Trentino Alto Adige` ripetuta due volte con prezzi diversi per GPL e metano. Quelle righe sono state scartate perché non si sa quale valore sia quello giusto.

## Aggiornamento

Ogni giorno alle 12:00 dal PC del curatore, perché dal 2026-10-17 www.mimit.gov.it accetta solo connessioni da IP italiani e GitHub Actions non lo raggiunge più. Script: `script/mimit-carburanti/mimit-carburanti.sh`.
