#!/bin/bash

#
# virtuoso自動更新のジョブ1ステップ1
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
TARGET_DATASETS['hgnc']=true
TARGET_DATASETS['efo']=true
TARGET_DATASETS['mondo']=true
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

#  作業用ディレクトリ (docker run の vオプションに指定するディレクトリはホスト側のディレクトリを参照する)
WORKDIR_ROOT="$(cd $(dirname $0); pwd)/../work"
WORKDIR="${WORKDIR_ROOT}/rdf-${DATASET}"
WORKDIR_DOWNLOAD="${WORKDIR_HOST}/rdf-${DATASET}_download"
WORKDIR_LOG="${WORKDIR_ROOT}/rdf-${DATASET}_logs"
YYYYMMDD=`LANG=C; date +%Y%m%d`
#
#  dockerファイルをgithubからpullする
#  ディレクトリがない場合はclone あればpull 
#  clone は　サブモジュールのアップデートも行
#  pull は　ログから更新あるか確認　あればフラグを立てる
#
if [ "${OPTION_g}" = "-g" ] &&  [ -d "${WORKDIR}" ]; then
  echo "Skip git clone https://github.com/biosciencedbc/rdf-${DATASET}"

elif [ -d "${WORKDIR}" ]; then
  cd $WORKDIR
  git pull > ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
  
  # サブモジュールの有無を確認
  sub_exist=`git submodule status | wc -l` 
  if [ $sub_exist -eq 0 ]; then
    git_log=`egrep "Already up to date." ${WORKDIR_LOG}/${YYYYMMDD}_build.log | wc -l`
    # git pullのログが1行ない場合（更新がある場合）
    # オプションfを指定してアーカイブファイルに更新がなくとも更新するようにする
    if [ ${git_log} -lt 1 ]; then
      OPTION_f="-f"
      echo "コンバータに更新がありました"
    fi
  else
    #git submodule update --recursive --init >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
    git submodule foreach git pull origin master >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
  
    git_log=`egrep "Already up to date." ${WORKDIR_LOG}/${YYYYMMDD}_build.log | wc -l` 
    # git pullのログが2行ない場合（更新がある場合）
    # オプションfを指定してアーカイブファイルに更新がなくとも更新するようにする
    if [ ${git_log} -lt 2 ]; then
      OPTION_f="-f"
      echo "コンバータに更新がありました"
    fi
  fi
else
  mkdir -p $WORKDIR_ROOT && mkdir -p ${WORKDIR_LOG}
  cd ${WORKDIR_ROOT}
  git clone https://github.com/biosciencedbc/rdf-${DATASET} > ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
    
  cd ${WORKDIR}
  #
  # gitのサブモジュールを最新に更新する
  #
  git submodule update --recursive --init >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
  git submodule foreach git pull origin master >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log 2>&1
  OPTION_f="-f"
  echo "コンバータに更新がありました"
fi

# docker imageのビルド
docker rmi rdf-${DATASET} >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log 
docker build --tag rdf-${DATASET} . >> ${WORKDIR_LOG}/${YYYYMMDD}_build.log
if [ $? -ne 0 ]; then
  echo "イメージのビルドに失敗しました"
  cat ${WORKDIR_LOG}/${YYYYMMDD}_build.log
  exit 1
fi

# RDFファイルを出力する空ディレクトリを作成する
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}

# 出力ディレクトリがすでにある場合
if [ -e ${OUTDIR} ]; then
  # 出力ディレクトリにファイルがある場合、コンバート済みとして異常終了
  if [ -n "$(ls $OUTDIR)" ]; then
    echo "本日分(${YYYYMMDD})はすでにコンバートされています"
    exit 1
  fi
# 出力ディレクトリがない場合、出力先ディレクトリを作成する
else 
  mkdir -p $OUTDIR
fi

#
# docker containerの実行
# pull でコンバータに更新がある場合は -f つけて実行
# docker stop/killでサブプロセスも含めて綺麗に停止できそう。stopもSIGTERMでなくSIGKILLで止めているようなのでkillの方が速く止まる
#
docker run --rm -v ${WORKDIR_DOWNLOAD}:/work -v ${OUTDIR}:/data --name "rdf-${DATASET}-${YYYYMMDD}" rdf-${DATASET} ${OPTION_f} ${OPTION_P} 1> ${WORKDIR_LOG}/${YYYYMMDD}_stdout.log  2> ${WORKDIR_LOG}/${YYYYMMDD}_stderr.log

#convert_rdf_make.sh
# 出力されたログファイルからエラーの有無を確認
# エラーがあれば異常終了
#
LOG_SIZE=`wc -c ${WORKDIR_LOG}/${YYYYMMDD}_stderr.log | awk '{print $1}'`
if [ ! $LOG_SIZE -eq 0 ]; then
  cat ${WORKDIR_LOG}/${YYYYMMDD}_stderr.log 1>&2
  exit 1
else
  # cat ${OUTDIR}/stdout.log 
  # ステップ2に渡すディレクトリ作成名(作成日時)を更新する
  #awk -v date=${YYYYMMDD} -v dataset=${DATASET} '{FS="\t";OFS="\t"}$1==dataset{$2=date}1' ${WORKDIR_ROOT}/rdf-update.tsv | tee ${WORKDIR_ROOT}/rdf-update.tsv >/dev/null 2>&1
  echo "${YYYYMMDD}" > ${WORKDIR_ROOT}/${DATASET}_update.txt
  exit 0
fi


