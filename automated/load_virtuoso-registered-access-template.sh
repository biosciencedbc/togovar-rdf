#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

YYYYMMDD=`LANG=C; date +%Y%m%d`								# 実行日
VIRTUOSO_DIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access_load/template/data"		# rundeckコンテナでのvirtuosoファイル出力先
DOCKER_DIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access-template"			# virtuosoのDockerfile配置先
DOCKER_LOG_DIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access_load/template/logs"	# ログの出力先
VIRTUOSO_HOST_DIR="${ROOT_DIR}/virtuoso-registered-access_load/template/data"		# virtuosoファイル出力先 
OUTDIR="/mnt/data01/togovar/togovar-data/registered_access/rdf/tier1/GRCh37"
IMAGE_NAME="virtuoso-registered-access-template"

# virtuosoの初期化
if [ -d ${VIRTUOSO_DIR} ];then
  rm -rf ${VIRTUOSO_DIR}
fi

mkdir -p ${VIRTUOSO_DIR} && mkdir -p ${DOCKER_LOG_DIR}

# Docker の更新
docker rmi ${IMAGE_NAME}
docker build --tag ${IMAGE_NAME} ${DOCKER_DIR}

echo "load start"

# ロードの実行
docker run --rm -v ${VIRTUOSO_HOST_DIR}:/database -v ${OUTDIR}:/load:ro ${IMAGE_NAME} 1> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stdout.log 2> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log

echo "load finish"

# ロード結果確認、エラーがあれば出力して異常終了
if [ -s ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log ]; then
  cat ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log >&2
  exit 1
fi

echo "finish"

