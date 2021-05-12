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
#TOGOVAR_VIRTUOSO_LOADER_DIR=/home/togovar/togovar/togovar-dev/togovar-virtuoso-loader/togovar-data/data/virtuoso
#STORE_BK_DIR=/mnt/share/togovar/store.bk/dgx1/data/virtuoso

echo "make backup"

# バックアップの作成
cp ${TOGOVAR_DEV_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx_bk 
cp ${TOGOVAR_DEV_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db_bk 


echo "update"

# 差し替えの実行
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx ${TOGOVAR_DEV_DIR}/virtuoso.trx
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.db ${TOGOVAR_DEV_DIR}/virtuoso.db   


# togovar-devの再起動

TOGOVAR_DEV_DOCKER_DIR=/home/rundeck/togovar-develop-docker

cd ${TOGOVAR_DEV_DOCKER_DIR}
docker-compose restart


echo "finish"


