#!/bin/bash

# RDF化対象のデータセット名
DATASET=hgnc

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf" 

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
nohup wget -c -nd -N https://raw.githubusercontent.com/med2rdf/hgnc/master/hgnc_complete_set.ttl 2> ${OUTDIR}/stdout.log &
gzip hgnc_complete_set.ttl
