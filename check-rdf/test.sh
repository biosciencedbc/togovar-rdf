#!/bin/bash

#
# virtuosoへロードを行いエラーがあれば出力する
# 1行目 対象ファイル数
# 2行目 エラー数
# 3行目以降 エラーファイルと内容
# -p RDFファイルのパターンを指定、指定がなければロード対象ディレクトリ以下すべてのファイルをロードする
#

HOST=localhost
ISQL=isql
PORT=1111
USER=dba
PASSWORD=dba
PATTERN=*

while getopts p: OPT
do
  case $OPT in
    p) PATTERN=$OPTARG ;;
  esac
done

# virtuosoの起動
/virtuoso-entrypoint.sh > /dev/null 2>&1 &

sleep 180

# ロード対象ファイルの追加(ロード対象ディレクトリは/loadに固定) 
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="ld_dir('/load', '${PATTERN}', 'check');"

# ロード対象ファイル数を表示
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="SELECT COUNT(*) FROM DB.DBA.LOAD_LIST where ll_state = 0;"

# ロードの実行
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="rdf_loader_run();" 

# エラー数を表示
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="SELECT COUNT(*) FROM DB.DBA.LOAD_LIST WHERE ll_error IS NOT NULL;"

# エラー一覧を表示(無ければ出力なし)
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="SELECT * FROM DB.DBA.LOAD_LIST WHERE ll_error IS NOT NULL;"



