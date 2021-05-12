#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

YYYYMMDD=`LANG=C; date +%Y%m%d`


# データセットごとの作成日時を読み込む
DATASETS=("clinvar" "ensembl" "hgnc" "medgen" "pubmed" "pubtator" "nlm-catalog")
WORK_DIR="${DOCKER_ROOT_DIR}/work"
declare -A DATASETS_DATE

for dataset in ${DATASETS[@]}; do
  dataset_date=`cat ${WORK_DIR}/${dataset}_update.txt`
  DATASETS_DATE["${dataset}"]=${dataset_date}
done

# virtuosoの初期化
VIRTUOSO_DIR="${DOCKER_ROOT_DIR}/data"

if [ -d ${VIRTUOSO_DIR} ];then
  rm -rf ${VIRTUOSO_DIR}
fi

mkdir ${VIRTUOSO_DIR}



# Docker の更新
DOCKER_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch"
docker rmi virtuoso-switch
docker build --tag virtuoso-switch ${DOCKER_DIR}

DOCKER_LOG_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch_logs"

echo "load start "

VIRTUOSO_HOST_DIR="${ROOT_DIR}/data"
# ロードの実行
docker run --rm -v ${VIRTUOSO_HOST_DIR}:/data -v ${OUTDIR}:/load/virtuoso:ro virtuoso-switch 1> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stdout.log 2> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log

echo "load finish"

# ロード結果確認、エラーがあれば出力して異常終了
if [ -s ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log ]; then
  cat ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log >&2
  exit 1
fi

# ロードした7つの対象データセットの更新日をファイルに出力
DATE_FILE=${VIRTUOSO_DIR}/dataset_date.tsv
touch ${DATE_FILE}

for dataset in ${!DATASETS_DATE[@]}; do
  echo -e "${dataset}\t${DATASETS_DATE[$dataset]}">> ${DATE_FILE}
done

echo "finish"

