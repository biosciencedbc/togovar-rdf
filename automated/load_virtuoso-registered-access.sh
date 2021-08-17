#

#
# virtuso更新自動化 ジョブX
# registered access用virtuosoへのロード
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
DOCKER_DIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access"
docker rmi virtuoso-registerd-access
docker build --tag virtuoso-registered-access ${DOCKER_DIR}

DOCKER_LOG_DIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access_logs"

echo "load start "

VIRTUOSO_HOST_DIR="${ROOT_DIR}/data"
# ロードの実行
docker run --rm -v ${VIRTUOSO_HOST_DIR}:/data -v ${OUTDIR}:/load/virtuoso:ro virtuoso-registered-access 1> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stdout.log 2> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log

echo "load finish"

# ロード結果確認、エラーがあれば出力して異常終了
if [ -s ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log ]; then
  cat ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log >&2
  exit 1
fi

#cp -r ${VIRTUOSO_DIR} /home/rundeck/virtuoso-tmp/

echo "finish"
