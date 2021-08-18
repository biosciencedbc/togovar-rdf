#!/bin/bash

# 
#  RDFファイルダウンロード用 共通スクリプト
# 

#
# 対象データセット
# mesh
# hco
# 
FORCE_CONVERT=0

# -f オプションはダウンロードサイトに新ファイルがなくてもコンバートする
# -g Dockerfileをgit cloneしない (デバッグ時に利用する)
# -P オプションは並列実行プロセス数
#
while getopts f OPT
do
  case $OPT in
    f) FORCE_CONVERT=1 ;;
  esac
done
shift $(($OPTIND - 1))

# RDF化対象のデータセット名
DATASET=$1

#
#  処理対象となっているデータセット一覧
#
declare -A TARGET_DATASETS
TARGET_DATASETS['mesh']=true
TARGET_DATASETS['hco']=true

#
#  データセット一覧に含まれているかチェック
#
if [ ${#DATASET} == 0 ]; then
  echo "Usage: download-rdf.sh [-f] DATASET"
  exit 0
elif ! test "${TARGET_DATASETS[$DATASET]+isset}"; then
  echo "Usage: download-rdf.sh [-f] DATASET"
  exit 0
fi

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

WORKDIR_ROOT="$(cd $(dirname $0); pwd)/../work"
WORKDIR="${WORKDIR_ROOT}/rdf-${DATASET}"
WORKDIR_DOWNLOAD="${WORKDIR_ROOT}/rdf-${DATASET}_download"
WORKDIR_LOG="${WORKDIR_ROOT}/rdf-${DATASET}_logs"
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR_ROOT=${OUTDIR}/${DATASET}
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}

# mesh
if [ ${DATASET} = mesh ]; then
  
  # 出力ディレクトリがすでにあり、ファイルがある場合、コンバート済みとして異常終了
  if [ -e ${OUTDIR} ]  && [ -n "$(ls $OUTDIR)" ]; then  
    echo "本日分(${YYYYMMDD})はすでにコンバートされています"
    exit 1    
  fi

  mkdir -p ${WORKDIR_DOWNLOAD} && mkdir -p ${WORKDIR_LOG} && mkdir -p ${OUTDIR}

  # ワークディレクトリにダウンロード
  cd ${WORKDIR_DOWNLOAD}
  wget -N ftp://ftp.nlm.nih.gov/online/mesh/rdf/mesh.nt.gz 2> ${WORKDIR_LOG}/${YYYYMMDD}_stdout.log 
  chmod 777 mesh.nt.gz
  num_of_newfiles=`egrep " saved \[+[0-9]+\]" "${WORKDIR_LOG}/${YYYYMMDD}_stdout.log" | grep -v "'.listing' saved" | wc -l`
  # 更新がなく、fオプションが指定されていなければ更新せず正常終了
  if [ ${num_of_newfiles} -eq 0 ] && [ ${FORCE_CONVERT} -eq 0 ]; then
    echo "mesh に更新はありません "
    exit 0
  fi
  # 出力先ディレクトリにコピー
  cp mesh.nt.gz ${OUTDIR}
  chmod 777 ${OUTDIR}/mesh.nt.gz
  echo "${YYYYMMDD}" > ${WORKDIR_ROOT}/${DATASET}_update.txt
  exit 0
fi

# hco
if [ ${DATASET} = hco ]; then
  
fi



