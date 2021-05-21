#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

YYYYMMDD=`LANG=C; date +%Y%m%d`

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

echo "finish"

