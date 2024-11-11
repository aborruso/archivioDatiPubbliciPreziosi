# Nota

Scaricati da web archive a partire da questo archivio:

```bash
curl 'https://web.archive.org/web/timemap/json?url=https%3A%2F%2Fwww.interno.gov.it%2Fsites%2Fdefault%2Ffiles&matchType=prefix&collapse=urlkey&output=json&fl=original%2Cmimetype%2Ctimestamp%2Cendtimestamp%2Cgroupcount%2Cuniqcount&filter=%21statuscode%3A%5B45%5D..&limit=10000&_=1731313541311&filter=original:.*omicid.*' \
  -H 'accept: application/json, text/javascript, */*; q=0.01' \
  -H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
  -H 'priority: u=1, i' \
  -H 'referer: https://web.archive.org/web/*/https://www.interno.gov.it/sites/default/files*' \
  -H 'sec-ch-ua: "Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
  -H 'x-requested-with: XMLHttpRequest' | jq -c '
.[]
| select(.[0] != "original")
| {
    original: .[0],
    mimetype: .[1],
    timestamp: .[2],
    endtimestamp: .[3],
    groupcount: .[4],
    uniqcount: .[5]
}' >output.jsonl
```

E poi dai dati grezzi si è costruito il download (vedi [#16](https://github.com/aborruso/archivioDatiPubbliciPreziosi/issues/16)).

Sono utile per le fase in cui non erano presenti i `CSV`.
