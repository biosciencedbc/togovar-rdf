#!/bin/bash

#
# virtuoso差し替え用スクリプト
# 切替先
# togovar-dev
# togovar-virtuoso-loader
# store.bk
# 

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

VIRTUOSO_SWITCH_DIR=${DOCKER_ROOT_DIR}/data
TOGOVAR_DEV_DIR=/home/rundeck/togovar-data/virtuoso
TOGOVAR_DEV_DOCKER_DIR=/home/rundeck/togovar-develop-docker
#TOGOVAR_VIRTUOSO_LOADER_DIR=/home/togovar/togovar/togovar-dev/togovar-virtuoso-loader/togovar-data/data/virtuoso
#STORE_BK_DIR=/mnt/share/togovar/store.bk/dgx1/data/virtuoso

# ロックファイルの確認、あれば切替用virtuosoへのロードジョブ実施中として異常終了
if [ -e ${VIRTUOSO_SWITCH_DIR}/job2.lck ];then
  echo "切替用virtuosoへのロードジョブが実行中です"
  exit 1
fi

# togovar-devの停止
cd ${TOGOVAR_DEV_DOCKER_DIR}
docker-compose exec -T virtuoso isql-v 1111 dba dba exec="checkpoint"
exec_1=`echo $?`
docker-compose exec -T virtuoso isql-v 1111 dba dba -K
exec_2=`echo $?`

# togovar-devの停止に失敗した場合異常終了する
if [ ${exec_1} -ne 0 ] || [ ${exec_2} -ne 0 ]; then
  echo "togovar-devの停止に失敗しました"
  exit 1
fi

echo "make backup"

# バックアップの作成
cp ${TOGOVAR_DEV_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx_bk 
cp ${TOGOVAR_DEV_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db_bk 


echo "update"

# 差し替えの実行
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db   


# togovar-devの再起動
docker-compose start virtuoso


echo "finish"


