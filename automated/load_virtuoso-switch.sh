#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

YYYYMMDD=`LANG=C; date +%Y%m%d`
VIRTUOSO_DIR="${DOCKER_ROOT_DIR}/data"
DOCKER_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch"
DOCKER_LOG_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch_logs"
VIRTUOSO_HOST_DIR="${ROOT_DIR}/data"
TEMPLATE_VIRTUOSO_DIR=""

# テンプレートのコピー
# cp ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx ${VIRTUOSO_DIR}/virtuoso.trx  
# cp ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db ${VIRTUOSO_DIR}/virtuoso.db 
#
# virtuosoの初期化
if [ -d ${VIRTUOSO_DIR} ];then
  rm -rf ${VIRTUOSO_DIR}
fi

mkdir ${VIRTUOSO_DIR}
# ロックファイルの作成
touch ${VIRTUOSO_DIR}/job2.lck


# Docker の更新
docker rmi virtuoso-switch
docker build --tag virtuoso-switch ${DOCKER_DIR}

echo "load start "

# ロードの実行
docker run --rm -v ${VIRTUOSO_HOST_DIR}:/data -v ${OUTDIR}:/load/virtuoso:ro virtuoso-switch 1> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stdout.log 2> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log

echo "load finish"

# ロード結果確認、エラーがあれば出力して異常終了
if [ -s ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log ]; then
  cat ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log >&2
  exit 1
fi

cp -r ${VIRTUOSO_DIR} /home/rundeck/virtuoso-tmp/

# ロックファイルの削除
rm ${VIRTUOSO_DIR}/job2.lck

echo "finish"

