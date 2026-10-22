# Note

Dal 10 febbraio 2026 il file sorgente MIMIT usa come separatore `|` invece di `;`. Fra il 10 febbraio e il 22 ottobre 2026 i due file qui sotto sono rimasti vuoti, perché lo script cercava ancora `;`.

## anagrafica_impianti_attivi.csv

Questo è un file da cui - rispetto al file sorgente - vengono:

- rimosse tutte le righe che contengono entità HTML, cercando le righe che contengono `&#`;
- rimosse tutte le righe con più di 10 campi;
- rimosse le righe che contengono `;` in un campo, perché questo file usa `;` come separatore.

## anagrafica_impianti_attivi-cleaned.csv

Questo è un file in cui, rispetto al file sorgente:

- vengono rimosse tutte le `"`;
- le entità HTML presenti sono interpretate e convertite nelle stringhe corrispondenti;
- vengono rimosse tutte le righe con più di 10 campi;
- il separatore di campo viene convertito da `|` a `,`.

Questo file quindi contiene più righe.
