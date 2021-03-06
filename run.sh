#!/bin/bash

#
# -f オプションはダウンロードサイトに新ファイルがなくてもコンバートする
# -g Dockerfileをgit cloneしない (デバッグ時に利用する)
# -P オプションは並列実行プロセス数
#
while getopts fgP: OPT
do
  case $OPT in
     f) OPTION_f="-f" ;;
     g) OPTION_g="-g" ;;
     P) OPTION_P="-P$OPTARG" ;;
  esac
done

shift $(($OPTIND - 1))

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
  echo "Usage: run.sh [-f] [-P number of threads] DATASET"
  exit 0
elif ! test "${TARGET_DATASETS[$DATASET]+isset}"; then
  echo "Usage: run.sh [-f] [-P number of threads] DATASET"
  exit 0
fi  

#  作業用ディレクトリ
WORKDIR_ROOT="$(cd $(dirname $0); pwd)/work"
WORKDIR="${WORKDIR_ROOT}/rdf-${DATASET}"
WORKDIR_DOWNLOAD="${WORKDIR_ROOT}/rdf-${DATASET}_download"

#
#  dockerファイルをgithubからclone/pullする
#
if [ "${OPTION_g}" = "-g" ] &&  [ -d "${WORKDIR}" ]; then
  echo "Skip git clone https://github.com/biosciencedbc/rdf-${DATASET}"
else
  mkdir -p $WORKDIR_ROOT
  cd $WORKDIR_ROOT
  rm -rf $WORKDIR
  git clone https://github.com/biosciencedbc/rdf-${DATASET}

  cd "$WORKDIR"
  #
  # gitのサブモジュールを最新に更新する
  #
  git submodule update --recursive --init
  git submodule foreach git pull origin master
fi

# docker imageのビルド
docker rmi rdf-${DATASET} 
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
nohup docker run --rm -v ${WORKDIR_DOWNLOAD}:/work -v ${OUTDIR}:/data --name "rdf-${DATASET}-${YYYYMMDD}" rdf-${DATASET} ${OPTION_f} ${OPTION_P} 1> ${OUTDIR}/stdout.log  2> ${OUTDIR}/stderr.log &