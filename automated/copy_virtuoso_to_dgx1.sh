#
# virtuosoファイルをdgx1にコピーする
#
#
#

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"
VIRTUOSO_DIR="${ROOT_DIR}/data"

# コピー元にvirtuoso.db,virtuoso.trxが存在しない場合は異常終了する
if [ ! -e ${VIRTUOSO_DIR}/virtuoso.db ] || [ ! -e ${VIRTUOSO_DIR}/virtuoso.trx ]; then
  echo "コピー元のvirtuoso.db または virtuoso.trx が存在しません"
  exit 1
fi

ssh dgx1 test -e ${DGX1_VIRTUOSO_DIR}/job2.lck
lck_exist=$?

# コピー先にjob2.lckが存在する場合 異常終了
if [  ${lck_exist} = 0 ]; then
  echo "dgx1にて同ジョブが実行中です"
  exit 1
fi

# ロックファイルの作成
ssh dgx1 touch ${DGX1_VIRTUOSO_DIR}/job2.lck

echo "copy file to dgx1"

# dgx1にvirtuosoファイルをコピーする
rsync -r ${VIRTUOSO_DIR}/ togovar@dgx1:${DGX1_VIRTUOSO_DIR}

# ロックファイルの削除
ssh dgx1 rm ${DGX1_VIRTUOSO_DIR}/job2.lck

echo "finish"

