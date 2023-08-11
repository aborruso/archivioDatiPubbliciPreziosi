# Note

## anagrafica_impianti_attivi.csv

Questo è un file da cui - rispetto al file sorgente - vengono:

- rimosse tutte le righe che contengono entità HTML, cercando le righe che contengono `&#`;
- rimosse tutte le righe con più di 10 campi.

## anagrafica_impianti_attivi-cleaned.csv

Questo è un file in cui, rispetto al file sorgente:

- vengono rimosse tutte le `"`;
- le entità HTML presenti sono interpretate e convertite nelle stringhe corrispondenti;
- vengono rimosse tutte le righe con più di 10 campi;
- il separatore di campo viene convertito da `;` a `,`.

Questo file quindi contiene più righe.
