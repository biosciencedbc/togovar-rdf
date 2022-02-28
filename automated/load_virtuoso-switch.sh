#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

YYYYMMDD=`LANG=C; date +%Y%m%d`					# 実行日
VIRTUOSO_DIR="${DOCKER_ROOT_DIR}/data"				# rundeckコンテナでのvirtuosoファイル出力先
DOCKER_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch"			# virtuosoのDockerfile配置先
DOCKER_LOG_DIR="${DOCKER_ROOT_DIR}/virtuoso-switch_logs"	# ログの出力先
VIRTUOSO_HOST_DIR="${ROOT_DIR}/data"				# virtuosoファイル出力先 
TEMPLATE_VIRTUOSO="/mnt/share/togovar/virtuoso-template/2022.1"	# gnomad等の事前ファイルがロードされているvirtuosoファイル

# job2.lckが存在する場合、異常終了
if [ -e ${VIRTUOSO_DIR}/job2.lck ]; then 
  echo "ジョブ2は既に実行中です"
  exit 1
fi 

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
time echo `md5sum ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.db | awk '{ print $1 }'` > ${VIRTUOSO_DIR}/virtuoso.db_before_md5

# テンプレートのコピー
# cp ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx ${VIRTUOSO_DIR}/virtuoso.trx  
time cp ${TEMPLATE_VIRTUOSO}/virtuoso.db ${VIRTUOSO_DIR}/virtuoso.db 

# コピー後のハッシュ値取得
#echo `md5sum ${VIRTUOSO_DIR}/virtuoso.trx | awk '{ print $1 }'` > ${VIRTUOSO_DIR}/virtuoso.trx_md5
time echo `md5sum ${VIRTUOSO_DIR}/virtuoso.db | awk '{ print $1 }'` > ${VIRTUOSO_DIR}/virtuoso.db_after_md5

# コピー前後のMDハッシュ値比較
#diff ${TEMPLATE_VIRTUOSO_DIR}/virtuoso.trx_md5 ${VIRTUOSO_DIR}/virtuoso.trx_md5
#exec_1=`echo $?`
diff ${VIRTUOSO_DIR}/virtuoso.db_before_md5 ${VIRTUOSO_DIR}/virtuoso.db_after_md5
exec_2=`echo $?`

# コピーしたファイルのハッシュ値が一致しない場合異常終了する
if [ ${exec_2} -ne 0 ]; then
  echo "DBファイルのコピーに失敗しました"
  exit 1
fi

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
  rm ${VIRTUOSO_DIR}/job2.lck
  exit 1
fi

# ロックファイルの削除
rm ${VIRTUOSO_DIR}/job2.lck

echo "finish"

