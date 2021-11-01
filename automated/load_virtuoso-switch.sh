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


# virtuosoの初期化
if [ -d ${VIRTUOSO_DIR} ];then
  rm -rf ${VIRTUOSO_DIR}
fi

mkdir ${VIRTUOSO_DIR} && mkdir -p ${DOCKER_LOG_DIR}
# ロックファイルの作成
touch ${VIRTUOSO_DIR}/job2.lck


echo "copy file"

# コピー前のハッシュ値取得
#echo `md5sum ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx | awk '{ print $1 }'` > ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx_md5
#echo `md5sum ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db | awk '{ print $1 }'` > ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db_md5
#
# テンプレートのコピー
# cp ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx ${VIRTUOSO_DIR}/virtuoso.trx  
# cp ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db ${VIRTUOSO_DIR}/virtuoso.db 
#
#
# コピー後のハッシュ値取得
#echo `md5sum ${VIRTUOSO_DIR}/virtuoso.trx | awk '{ print $1 }'` > ${VIRTUOSO_DIR}/virtuoso.trx_md5
#echo `md5sum ${VIRTUOSO_DIR}/virtuoso.db | awk '{ print $1 }'` > ${VIRTUOSO_DIR}/virtuoso.db_md5
#
# コピー前後のMDハッシュ値比較
#diff ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx_md5 ${VIRTUOSO_DIR}/virtuoso.trx_md5
#exec_1=`echo $?`
#diff ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db_md5 ${VIRTUOSO_DIR}/virtuoso.db_md5
#exec_2=`echo $?`
#
# コピーしたファイルのハッシュ値が一致しない場合異常終了する
#if [ ${exec_1} -ne 0 ] || [ ${exec_2} -ne 0 ]; then
#  echo "DBファイルのコピーに失敗しました"
#  exit 1
#fi

# Docker の更新
docker rmi virtuoso-switch
docker build --tag virtuoso-switch ${DOCKER_DIR}

echo "load start"

# ロードの実行
docker run --rm -v ${VIRTUOSO_HOST_DIR}:/database -v ${OUTDIR}:/load/virtuoso:ro virtuoso-switch 1> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stdout.log 2> ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log

echo "load finish"

# ロード結果確認、エラーがあれば出力して異常終了
if [ -s ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log ]; then
  cat ${DOCKER_LOG_DIR}/${YYYYMMDD}_stderr.log >&2
  exit 1
fi

cp -r ${VIRTUOSO_DIR} /mnt/share/togovar/virtuoso-tmp

# ロックファイルの削除
rm ${VIRTUOSO_DIR}/job2.lck

echo "finish"

