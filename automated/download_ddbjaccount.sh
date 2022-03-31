#

#
# JGA user list ダウンロード用スクリプト
# 公開ディレクトリにダウンロードディレクトリを設定しないこと
#


# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
#source "${SCRIPT_DIR}/global.conf"
source "${SCRIPT_DIR}/registered-access.conf"

#WORKDIR="/home/togovar/togovar/togovar-dev/togovar-rdf/virtuoso-registered-access/ddbjaccount/"
#WORKDIR="/mnt/share/togovar_h/load/virtuoso-registered-access"
WORKDIR="${DOCKER_ROOT_DIR}/virtuoso-registered-access_load/ddbjaccount"
WORKDIR_LOG="${WORKDIR}/logs"
YYYYMMDD=`LANG=C; date +%Y%m%d`
BACKUP_DIR="${WORKDIR}/backup"

# ログ用ディレクトリとバックアップ用ディレクトリを作成
mkdir -p ${WORKDIR_LOG} && mkdir -p ${BACKUP_DIR} 

# ワークディレクトリ移動
cd ${WORKDIR}

# バックアップ取得
if [ -e ${BACKUP_DIR}/list.ttl ]; then
  mv ${BACKUP_DIR}/list.ttl ${BACKUP_DIR}/list.ttl.bk
fi

if [ -e list.ttl ]; then
  cp list.ttl ${BACKUP_DIR}/list.ttl
fi

# jga_user.ttlの更新確認+取得
wget -N --http-user=${USER} --http-password=${PASS} https://ts-humandbs.ddbj.nig.ac.jp/users/list.ttl 2>${WORKDIR_LOG}/${YYYYMMDD}_stdout.log
if [ -e list.ttl ]; then
  chmod 777 list.ttl
fi
num_of_newfiles=`egrep "\[+[0-9/0-9]+\]" "${WORKDIR_LOG}/${YYYYMMDD}_stdout.log" | grep -v ".listing" | wc -l`

# 更新がなければバックアップを元に戻して正常終了
if [ ${num_of_newfiles} -eq 0 ]; then
  echo "list.ttl has not update "
  if [ -e ${BACKUP_DIR}/list.ttl ]; then 
    rm ${BACKUP_DIR}/list.ttl
  fi
  if [ -e ${BACKUP_DIR}/list.ttl.bk ]; then
    mv ${BACKUP_DIR}/list.ttl.bk ${BACKUP_DIR}/list.ttl
  fi 
  exit 0
fi

# 更新があった場合、2世代前のファイルを削除する
if [ -e ${BACKUP_DIR}/list.ttl.bk ]; then
  rm ${BACKUP_DIR}/list.ttl.bk
fi


echo "finish"

