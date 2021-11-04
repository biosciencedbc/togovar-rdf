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
  echo "${YYYYMMDD}" > ${WORKDIR_DOWNLOAD}/update.txt
  # ワークディレクトリにダウンロード
  cd ${WORKDIR_DOWNLOAD}
  wget -N ftp://ftp.nlm.nih.gov/online/mesh/rdf/mesh.nt.gz 2> ${WORKDIR_LOG}/${YYYYMMDD}_stdout.log 
  chmod 777 mesh.nt.gz
  num_of_newfiles=`egrep "\[+[0-9]+\]" "${WORKDIR_LOG}/${YYYYMMDD}_stdout.log" | grep -v ".listing" | wc -l`
  # 更新がなく、fオプションが指定されていなければ更新せず正常終了
  if [ ${num_of_newfiles} -eq 0 ] && [ ${FORCE_CONVERT} -eq 0 ]; then
    echo "mesh に更新はありません "
    exit 0
  fi
  # 出力先ディレクトリにコピー
  cp mesh.nt.gz ${OUTDIR}
  chmod 777 ${OUTDIR}/mesh.nt.gz
  exit 0
fi

# hco
if [ ${DATASET} = hco ]; then
  
  # 出力ディレクトリがすでにあり、ファイルがある場合、コンバート済みとして異常終了
  if [ -e ${OUTDIR} ]  && [ -n "$(ls $OUTDIR)" ]; then
    echo "本日分(${YYYYMMDD})はすでにコンバートされています"
    exit 1
  fi
  
  mkdir -p ${WORKDIR_DOWNLOAD} && mkdir -p ${WORKDIR_LOG} && mkdir -p ${OUTDIR}
  # ダウンロードディレクトリにファイルがある場合(初回実行でない)
  if [ -n "$(ls $WORKDIR_DOWNLOAD)" ]; then
    cd ${WORKDIR_DOWNLOAD}
    git pull > ${WORKDIR_LOG}/${YYYYMMDD}_git.log
    git_log=`egrep "Already up to date." ${WORKDIR_LOG}/${YYYYMMDD}_build.log | wc -l`
    echo "${YYYYMMDD}" > ${WORKDIR_DOWNLOAD}/update.txt
    # gitログにAlready up to date.の文字列が出力されている場合(更新が無い)、更新が無い旨を出力して正常終了する
    if [ ${git_log} -e 1 ]; then
      echo "mesh に更新はありません "
      exit 0
    fi
  # ダウンロードディレクトリにファイルがない場合(初回実行の場合)  
  else
    git clone https://github.com/med2rdf/hco.git ${WORKDIR_DOWNLOAD}
    echo "${YYYYMMDD}" > ${WORKDIR_DOWNLOAD}/update.txt
  fi
  cd ${WORKDIR_DOWNLOAD}
  # 出力先ディレクトリにコピー
  cp hco.ttl ${OUTDIR} && cp hco_head.ttl ${OUTDIR}
  chmod 777 ${OUTDIR}/hco.ttl ${OUTDIR}/hco_head.ttl
  exit 0  
fi



