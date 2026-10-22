#!/usr/bin/env python3
"""Ricostruisce docs/mimit-carburanti/storico.csv dalla storia git dei due file correnti.

Fino al 2026-10-22 lo script giornaliero scartava la riga "Aggiornamento GG-MM-AAAA",
quindi per le versioni passate la data è il giorno del commit (ora di Roma): i commit
sono uno al giorno, tutti dopo le 08:30, ora di pubblicazione MIMIT. Queste righe hanno
data_fonte=commit. Da lanciare una volta, dalla root del repo.
"""
import csv
import subprocess
from datetime import datetime
from zoneinfo import ZoneInfo

ROMA = ZoneInfo("Europe/Rome")
CARTELLA = "docs/mimit-carburanti"
FILE = {"stradale": "media-regionale.csv", "autostradale": "media-autostrade.csv"}
CAMPI = ["data", "ambito", "area", "carburante", "erogazione", "prezzo", "data_fonte"]


def git(*args):
    return subprocess.run(["git", *args], check=True, capture_output=True).stdout


righe = {}
ambigue = set()
for ambito, nome in FILE.items():
    percorso = f"{CARTELLA}/{nome}"
    for riga in git("log", "--format=%H %cI", "--", percorso).decode().splitlines():
        sha, ts = riga.split()
        data = datetime.fromisoformat(ts).astimezone(ROMA).date().isoformat()
        try:
            testo = git("show", f"{sha}:{percorso}").decode("utf-8")
        except subprocess.CalledProcessError:
            continue  # file cancellato in quel commit
        for r in list(csv.reader(testo.splitlines()))[1:]:
            if len(r) < 4:
                continue
            area = "Italia" if ambito == "autostradale" else r[0]
            chiave = (data, ambito, area, r[1], r[2])
            # stessa chiave due volte nello stesso file con prezzi diversi: non si sa quale tenere
            if chiave in righe and righe[chiave] != r[3]:
                ambigue.add(chiave)
            righe[chiave] = r[3]

for chiave in sorted(ambigue):
    print("scartata, prezzi diversi per la stessa chiave:", *chiave)
    del righe[chiave]

with open(f"{CARTELLA}/storico.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f, lineterminator="\n")
    w.writerow(CAMPI)
    for chiave in sorted(righe):
        w.writerow([*chiave, righe[chiave], "commit"])
