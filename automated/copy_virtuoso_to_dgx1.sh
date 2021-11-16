#
# virtuosoファイルをdgx1にコピーする
#
#
#

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"
VIRTUOSO_DIR="${ROOT_DIR}/data"

# ロックファイルの作成
ssh dgx1 touch ${DGX1_VIRTUOSO_DIR}/job2.lck

echo "copy file to dgx1"

# dgx1にvirtuosoファイルをコピーする
scp ${VIRTUOSO_DIR}/* togovar@dgx1:${DGX1_VIRTUOSO_DIR}

# ロックファイルの削除
ssh dgx1 rm ${DGX1_VIRTUOSO_DIR}/job2.lck

echo "finish"

