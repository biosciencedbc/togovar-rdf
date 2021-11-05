#!/bin/bash

#
# virtuoso差し替え用スクリプト
# 差し替え先
# togovar-dev2
# 

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

TOGOVAR_DEV_DIR=/home/rundeck/togovar-dev2/togovar-data/virtuoso
TOGOVAR_DEV_DOCKER_DIR=/home/rundeck/togovar-develop-docker

# ロックファイルの確認、あれば切替用virtuosoへのロードジョブ実施中として異常終了
if [ -e ${VIRTUOSO_SWITCH_DIR}/job2.lck ];then
  echo "切替用virtuosoへのロードジョブが実行中です"
  exit 1
fi


echo "copy file"

# コピー前のハッシュ値取得
echo `md5sum ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx | awk '{ print $1 }'` > ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx_md5
echo `md5sum ${VIRTUOSO_SWITCH_DIR}/virtuoso.db | awk '{ print $1 }'` > ${VIRTUOSO_SWITCH_DIR}/virtuoso.db_md5

# 最新のDBファイルをコピー
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx_tmp
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db_tmp

# コピー後のハッシュ値取得
echo `md5sum ${TOGOVAR_DEV_DIR}/virtuoso.trx_tmp | awk '{ print $1 }'` > ${TOGOVAR_DEV_DIR}/virtuoso.trx_md5
echo `md5sum ${TOGOVAR_DEV_DIR}/virtuoso.db_tmp | awk '{ print $1 }'` > ${TOGOVAR_DEV_DIR}/virtuoso.db_md5


echo "check hash"

# コピー前後のハッシュ値比較
diff ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx_md5 ${TOGOVAR_DEV_DIR}/virtuoso.trx_md5
exec_1=`echo $?`
diff ${VIRTUOSO_SWITCH_DIR}/virtuoso.db_md5 ${TOGOVAR_DEV_DIR}/virtuoso.db_md5
exec_2=`echo $?`

# コピーしたファイルのハッシュ値が一致しない場合一時ファイルを削除して異常終了する
if [ ${exec_1} -ne 0 ] || [ ${exec_2} -ne 0 ]; then
  echo "DBファイルのコピーに失敗しました"
  rm ${TOGOVAR_DEV_DIR}/virtuoso.trx_tmp
  rm ${TOGOVAR_DEV_DIR}/virtuoso.db_tmp
  exit 1
fi


echo "update"

# togovar-devの停止
cd ${TOGOVAR_DEV_DOCKER_DIR}
docker-compose exec -T virtuoso isql-v 1111 dba dba exec="checkpoint"
exec_3=`echo $?`
docker-compose exec -T virtuoso isql-v 1111 dba dba -K
exec_4=`echo $?`

# togovar-devの停止に失敗した場合異常終了する
if [ ${exec_3} -ne 0 ] || [ ${exec_4} -ne 0 ]; then
  echo "togovar-devの停止に失敗しました"
  exit 1
fi

# バックアップの作成
mv ${TOGOVAR_DEV_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx_bk
mv ${TOGOVAR_DEV_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db_bk

# 差し替えの実行
mv ${TOGOVAR_DEV_DIR}/virtuoso.trx_tmp ${TOGOVAR_DEV_DIR}/virtuoso.trx
mv ${TOGOVAR_DEV_DIR}/virtuoso.db_tmp ${TOGOVAR_DEV_DIR}/virtuoso.db

sleep 60

# togovar-devの再起動
docker-compose start virtuoso


echo "finish"


