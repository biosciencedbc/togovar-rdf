#

#
# virtuso更新自動化 ジョブ2
# 切替用virtuosoへのロード
#


VIRTUOSO_DIR="/home/rundeck/togovar-virtuoso-loader"

# virtuosoの初期化
${VIRTUOSO_DIR}/empty_virtuoso.sh

# ロードの実行
${VIRTUOSO_DIR}/exec_load_rdf.sh

# ロード結果確認

# チェックポイントの発行？（不要 or virtuosoの停止）

# ロードした7つの対象データセットの更新日をファイルに出力


