#!/bin/bash

#
# 自動化スクリプトのダウンロード・更新
#

SCRIPT_DIR="$(cd $(dirname $0); pwd)"

cd ${SCRIPT_DIR}/automated

# ジョブ1 コンバート処理
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/convert_rdf.sh -O convert_rdf.sh
# ジョブ1 ダウンロード処理(ダウンロードのみに使用)
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/download-rdf.sh -O download-rdf.sh
# ジョブ1 バリデート処理
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/validate_rdf.sh -O validate_rdf.sh

# ジョブ2 切替用virtuosoへのロード処理
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/load_virtuoso-switch.sh -O load_virtuoso-switch.sh
# ジョブ2 dgx１へのvirtuoso.dbコピー処理
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/copy_virtuoso_to_dgx1.sh -O copy_virtuoso_to_dgx1.sh

# registered access用　テンプレート作成ジョブ
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/load_virtuoso-registered-access-template.sh -O load_virtuoso-registered-access-template.sh

# registered access用virtuoso.db作成
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/load_virtuoso-registered-access-switch.sh -O load_virtuoso-registered-access-switch.sh

# registered access用userlistダウンロード処理
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/automated/download_ddbjaccount.sh -O download_ddbjaccount.sh

chmod 777 -R .

cd ${SCRIPT_DIR}

mkdir -p virtuoso-registered-access-switch
mkdir -p virtuoso-registered-access-template
mkdir -p virtuoso-switch

# registered-access 用 docker環境
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-registered-access-switch/Dockerfile -O virtuoso-registered-access-switch/Dockerfile
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-registered-access-switch/load.sh -O virtuoso-registered-access-switch/load.sh

# registered-access-template 用 docker環境
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-registered-access-template/Dockerfile -O virtuoso-registered-access-template/Dockerfile
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-registered-access-template/load.sh -O virtuoso-registered-access-template/load.sh

# 切替用 virtuoso docker環境
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-switch/Dockerfile -O virtuoso-switch/Dockerfile
wget https://raw.githubusercontent.com/biosciencedbc/togovar-rdf/master/virtuoso-switch/load.sh -O virtuoso-switch/load.sh
 

