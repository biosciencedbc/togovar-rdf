#!/bin/bash

#
# virtuoso差し替え用スクリプト
# 切替先 togovar-stg
# 

SCRIPT_DIR="$(cd $(dirname $0); pwd)"

VIRTUOSO_SWITCH_DIR=${SCRIPT_DIR}/data
TOGOVAR_STG_DIR=/mnt/vol1/togovar/togovar-data/virtuoso
TOGOVAR_STG_DOCKER_DIR=/ssd/togovar/togovar-docker

# ロックファイルの確認、あれば切替用virtuosoへのロードジョブ実施中として異常終了
if [ -e ${VIRTUOSO_SWITCH_DIR}/job2.lck ];then
  echo "切替用virtuosoへのロードジョブが実行中です"
  exit 1
fi


# 更新チェック,
# dataset_date.tsv存在チェック、あれば更新チェックを行う
if [ -e ${TOGOVAR_STG_DIR}/dataset_date.tsv  ];then
  update=`diff "${TOGOVAR_STG_DIR}/dataset_date.tsv" "${VIRTUOSO_SWITCH_DIR}/dataset_date.tsv" | wc -l` 
  # 更新の有無を出力
  if [ "${update}" -eq "0" ];then
    echo "前回実行分から更新がありません"
    #exit 0
  else
    echo "更新があります"
  fi  
fi


# togovar-devの停止
cd ${TOGOVAR_STG_DOCKER_DIR}
docker-compose exec -T virtuoso isql-v 1111 dba dba exec="checkpoint"
exec_1=`echo $?`
docker-compose exec -T virtuoso isql-v 1111 dba dba -K
exec_2=`echo $?`

# togovar-stgの停止に失敗した場合異常終了する
if [ ${exec_1} -ne 0 ] || [ ${exec_2} -ne 0 ]; then
  echo "togovar-stgの停止に失敗しました"
  exit 1
fi

echo "make backup"

# バックアップの作成
cp ${TOGOVAR_STG_DIR}/virtuoso.trx ${TOGOVAR_STG_DIR}/virtuoso.trx_bk 
cp ${TOGOVAR_STG_DIR}/virtuoso.db ${TOGOVAR_STG_DIR}/virtuoso.db_bk 


echo "update"

# 差し替えの実行
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.trx ${TOGOVAR_STG_DIR}/virtuoso.trx
cp ${VIRTUOSO_SWITCH_DIR}/virtuoso.db ${TOGOVAR_STG_DIR}/virtuoso.db   
cp ${VIRTUOSO_SWITCH_DIR}/dataset_date.tsv ${TOGOVAR_STG_DIR}/dataset_date.tsv

# togovar-stgの再起動
docker-compose start virtuoso


echo "finish"


