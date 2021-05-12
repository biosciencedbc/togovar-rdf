# togovar-rdf
RDF converter launchers for TogoVar.

## Datasets to convert

See [DATASETLIST.md](DATASETLIST.md)

## Run

Run rdf-${dataset_name}.sh to obtain RDF files of a dataset.

Each script launches a RDF coverter following downloading original files. Some of them only download RDF files from original sites.

## Where to output

RDF files are saved under $OUTDIR/${datasets}/.

OUTDIR is defined in global.conf, which is loaded in each script.

```
[togovar@nbdc709 togovar-rdf]$ cat global.conf
# Directory to write RDF files (write permission required)
OUTDIR=/mnt/share/togovar/load/virtuoso
export OUTDIR
[togovar@nbdc709 togovar-rdf]$
```

## Example

```
[togovar@nbdc709 togovar-rdf]$ ./rdf-hgnc.sh
/mnt/share/togovar/load/virtuoso/hgnc/20200528 ~/togovar-rdf
--2020-05-28 14:30:05--  https://raw.githubusercontent.com/med2rdf/hgnc/master/hgnc_complete_set.ttl
raw.githubusercontent.com (raw.githubusercontent.com) をDNSに問いあわせています... 151.101.228.133
raw.githubusercontent.com (raw.githubusercontent.com)|151.101.228.133|:443 に接続しています... 接続しました。
HTTP による接続要求を送信しました、応答を待っています... 200 OK
長さ: 70079655 (67M) [text/plain]
`hgnc_complete_set.ttl' に保存中

100%[===================================================================================================================>] 70,079,655  12.6MB/s 時間 5.2s

2020-05-28 14:30:13 (12.8 MB/s) - `hgnc_complete_set.ttl' へ保存完了 [70079655/70079655]

~/togovar-rdf
[togovar@nbdc709 togovar-rdf]$ ls -l /mnt/share/togovar/load/virtuoso/hgnc/20200528/
合計 5615
-rw-rw-r--. 1 togovar togovar 5749550  5月 28 14:30 hgnc_complete_set.ttl.gz
[togovar@nbdc709 togovar-rdf]$
```
