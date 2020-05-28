#!/bin/bash

# RDF化対象のデータセット名 
DATASET=$1

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

#
#  処理対象となっているデータセット一覧
#
declare -A TARGET_DATASETS
TARGET_DATASETS['clinvar']=true
TARGET_DATASETS['ensembl']=true
TARGET_DATASETS['nlm-catalog']=true
TARGET_DATASETS['medgen']=true
TARGET_DATASETS['pubmed']=true
TARGET_DATASETS['pubtator']=true

#
#  データセット一覧に含まれているかチェック
#
if [ ${#DATASET} == 0 ]; then
  echo "Usage: run.sh [DATASET]"
  exit 0
elif ! test "${TARGET_DATASETS[$DATASET]+isset}"; then
  echo "Usage: run.sh [DATASET]"
  exit 0
fi  

#  作業用ディレクトリ
WORKDIR_ROOT="$(cd $(dirname $0); pwd)/work"
WORKDIR="${WORKDIR_ROOT}/rdf-${DATASET}"
WORKDIR_DOWNLOAD="${WORKDIR_ROOT}/rdf-${DATASET}_download"

#
#  dockerファイルをgithubからclone/pullする
#
mkdir -p $WORKDIR_ROOT
cd $WORKDIR_ROOT
rm -rf $WORKDIR
git clone https://github.com/biosciencedbc/rdf-${DATASET}
cd "$WORKDIR"   
git submodule update --recursive --init

# docker imageのビルド
docker build --tag rdf-${DATASET} .

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

#
# docker containerの実行
#  　docker stop/killでサブプロセスも含めて綺麗に停止できそう。stopもSIGTERMでなくSIGKILLで止めているようなのでkillの方が速く止まる
#
nohup docker run --rm -v ${WORKDIR_DOWNLOAD}:/work -v ${OUTDIR}:/data --name "rdf-${DATASET}-${YYYYMMDD}" rdf-${DATASET} 1> ${OUTDIR}/stdout.log  2> ${OUTDIR}/stderr.log &

