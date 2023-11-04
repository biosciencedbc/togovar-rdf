#!/bin/bash

#
# ジョブ1 ステップ2
# テスト用のvirtuosoにロードしてRDFのバリデートを行う
#

# メタデータシート作成フラグ
MAKE_MATADATA=1
# Ensemblかどうか
ENSEMBL=0
while getopts ne OPT
do
  case $OPT in
    n) MAKE_MATADATA=0 
      ;;
    e) ENSEMBL=1
      ;;
  esac
done
shift $(($OPTIND - 1))


# RDF化対象のデータセット名
DATASET=$1

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"
WORKDIR_ROOT=${SCRIPT_DIR}/../work
WORKDIR_DOWNLOAD=${WORKDIR_ROOT}/rdf-${DATASET}_download
#
#  処理対象となっているデータセット一覧
#
declare -A TARGET_DATASETS
TARGET_DATASETS['clinvar']=true
TARGET_DATASETS['ensembl_grch37']=true
TARGET_DATASETS['ensembl_grch38']=true
TARGET_DATASETS['nlm-catalog']=true
TARGET_DATASETS['medgen']=true
TARGET_DATASETS['pubmed']=true
TARGET_DATASETS['pubtator']=true
TARGET_DATASETS['hgnc']=true
TARGET_DATASETS['efo']=true
TARGET_DATASETS['mondo']=true
TARGET_DATASETS['go']=true
TARGET_DATASETS['so']=true
TARGET_DATASETS['gwas-catalog']=true
TARGET_DATASETS['mesh']=true
TARGET_DATASETS['hco']=true
#
#  データセット一覧に含まれているかチェック
#
if [ ${#DATASET} == 0 ]; then
  echo "Usage: xxx.sh DATASET"
  exit 1
elif ! test "${TARGET_DATASETS[$DATASET]+isset}"; then
  echo "Usage: xxx.sh DATASET"
  exit 1
fi

# 更新日時ファイルからRDFファイルを出力したディレクトリを確認
YYYYMMDD=`cat ${WORKDIR_ROOT}/rdf-${DATASET}_download/update.txt`
#echo ${YYYYMMDD}
OUTDIR_ROOT=${DOCKER_OUTDIR}/${DATASET}
LATESTDIR=${DOCKER_OUTDIR}/${DATASET}/latest
OUTDIR_HOST=${OUTDIR}/${DATASET}/${YYYYMMDD}
OUTDIR=${DOCKER_OUTDIR}/${DATASET}/${YYYYMMDD}
#echo $OUTDIR
#
# RDFファイルの有無を確認
# なければ対象ディレクトリを削除して正常終了
#
FILECOUNT=`find ${OUTDIR} -type f | wc -l`

if [ ${FILECOUNT} -eq 0 ]; then
  rm -rf ${OUTDIR}
  echo "${DATASET} の更新はありません"
  #echo "RDF files were generated because no new files were found at the download site."
  exit 0
fi

#
# テスト用のvirtuosoにロード
#
RESULT=`docker run --rm -v ${OUTDIR_HOST}:/load check-rdf 2>&1` 
LOADCOUNT=`echo "${RESULT}" | sed -n -e 1p`
ERRORCOUNT=`echo "${RESULT}" | sed -n -e 2p`

#echo "RESULT : ${RESULT}"
echo "FILES_TO_LOAD : ${LOADCOUNT}"
echo "ERRORCOUNT : ${ERRORCOUNT}"

#
# ロード結果を確認してエラーがあればエラーを出力して異常終了
#

# ロード対象ファイル数が0だった場合異常終了
if [ ${LOADCOUNT} -eq 0 ]; then
  echo "ロード対象ファイルがありません"
  echo "対象ディレクトリ: ${OUTDIR} "
  exit 1
fi

# ロード結果のエラー数が0でない場合、エラー内容を出力して異常終了
if [[ ${ERRORCOUNT} =~ ^-?[0-9]+$ ]]; then
  if [ ! ${ERRORCOUNT} -eq 0 ]; then
    echo "ロード結果にエラーがあります"
    #ERRORLOG=`echo ${RESULT} | sed -n '2,$p'`
    echo "${RESULT}"
    exit 1
  fi
fi

#
# ロードしたディレクトリをlatestに設定
#
cd ${OUTDIR_ROOT}
ln -snf ${YYYYMMDD} latest

#
# メタデータファイルを実行日で更新して対象ディレクトリに出力
#
METADATA_DIR="${SCRIPT_DIR}/../metadata"
YYYY_MM_DD=`echo ${YYYYMMDD:0:4}-${YYYYMMDD:4:2}-${YYYYMMDD:6:2}`

# nオプションが指定されていなければメタデータを作成する
if [ ${MAKE_MATADATA} -eq 1 ]; then
  # metadataをRDFファイル出力ディレクトリにコピーする
  cp ${METADATA_DIR}/${DATASET}_metadata.yaml ${OUTDIR}/metadata.yaml
  cp ${METADATA_DIR}/${DATASET}_metadata_ja.yaml ${OUTDIR}/metadata_ja.yaml


  # 更新日(issued)を実行日に更新する
  sed -i -e "s/issued: .*$/issued: ${YYYY_MM_DD}/" ${OUTDIR}/metadata.yaml
  sed -i -e "s/issued: .*$/issued: ${YYYY_MM_DD}/" ${OUTDIR}/metadata_ja.yaml

  # バージョン(version)を更新する、Ensemblの場合はアーカイブファイルと同じ場所に保存されているversionを記載したファイルを参照する
  if [ ${ENSEMBL} -eq 1 ]; then
    ENSEMBL_VERSION=`cat ${WORKDIR_DOWNLOAD}/version.txt`
    sed -i -e "s/version: .*$/version: release_${ENSEMBL_VERSION}/" ${OUTDIR}/metadata.yaml 
    sed -i -e "s/version: .*$/version: release_${ENSEMBL_VERSION}/" ${OUTDIR}/metadata_ja.yaml
  else
    sed -i -e "s/version: .*$/version: release_${YYYYMMDD}/" ${OUTDIR}/metadata.yaml
    sed -i -e "s/version: .*$/version: release_${YYYYMMDD}/" ${OUTDIR}/metadata_ja.yaml
  fi
fi

echo "${DATASET} の最新ファイルは ${OUTDIR_HOST} に出力されました"
#
# 完了
#


