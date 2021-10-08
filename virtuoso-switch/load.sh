#!/bin/bash

# 切替用virtuosoへのロード実行
# ロード対象ディレクトリ: $LOAD_DATA_BASE
# virtuoso関連ファイル: /data
# 

HOST=localhost
ISQL=isql-v
PORT=1111
USER=dba
PASSWORD=dba
PARALLEL=10

# load対象ファイルのグラフ名一覧
DATASETS=()

function add_load_list() {
  local path=${1:?}
  local pattern=${2:?}
  local graph=${3:?}
    
  ${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="ld_dir('${path}', '${pattern}', '${graph}');"

  DATASETS=("${DATASETS[@]}" "${graph}")
}


LOAD_DATA_BASE="/load"

# virtuosoの起動
/virtuoso.sh > /dev/null 2>&1 &

sleep 180

now=`date "+%Y%m%d-%H%M%S"`
echo "Started load.sh at $now"

# latestの参照先のディレクトリを取得
DATASETS=("clinvar" "ensembl_grch37" "ensembl_grch38" "hgnc" "medgen" "pubmed" "pubtator" "nlm-catalog" "efo" "mondo" "so" "go" "gwas-catalog" "mesh" "hco")
WORK_DIR="${DOCKER_ROOT_DIR}/work"
declare -A DATASETS_DATE

for dataset in ${DATASETS[@]}; do
  dataset_date=`readlink ${LOAD_DATA_BASE}/virtuoso/${dataset}/latest`
  DATASETS_DATE["${dataset}"]=${dataset_date}
done

# ロード対象の追加
# add_load_list [ロード対象ファイルのあるディレクトリ] '[対象ファイルのプレフィックス]' '[グラフ名]'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant/v3 '*.nt.gz' 'http://togovar.biosciencedbc.jp/variation'

add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_condition/clinvar/v3 'clinvar*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/annotation/clinvar'

add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3/ 'HGVD.*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/hgvd'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3/ 'JGA-SNP.*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/jga_ngs'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3/ 'JGA-NGS.*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/jga_snp'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3 '4.7K.*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/tommo_4.7kjpn'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3 '10K.*.nt.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/gem_j_wga'
add_load_list ${LOAD_DATA_BASE}/virtuoso/variant_frequency/v3 'ExAC.*.ttl.gz' 'http://togovar.biosciencedbc.jp/variation/frequency/exac'

add_load_list ${LOAD_DATA_BASE}/virtuoso/clinvar/${DATASETS_DATE["clinvar"]} '*.ttl.gz' 'http://togovar.biosciencedbc.jp/clinvar'
add_load_list ${LOAD_DATA_BASE}/virtuoso/ensembl_grch37/${DATASETS_DATE["ensembl_grch37"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/ensembl37'
add_load_list ${LOAD_DATA_BASE}/virtuoso/gwas-catalog/${DATASETS_DATE["gwas-catalog"]} '*' 'http://togovar.biosciencedbc.jp/gwas-catalog'
add_load_list ${LOAD_DATA_BASE}/virtuoso/efo/${DATASETS_DATE["efo"]} '*.owl' 'http://togovar.biosciencedbc.jp/efo'
add_load_list ${LOAD_DATA_BASE}/virtuoso/hco/${DATASETS_DATE["hco"]} '*.ttl' 'http://togovar.biosciencedbc.jp/hco'
add_load_list ${LOAD_DATA_BASE}/virtuoso/hgnc/${DATASETS_DATE["hgnc"]} '*.ttl' 'http://togovar.biosciencedbc.jp/hgnc'
add_load_list ${LOAD_DATA_BASE}/virtuoso/medgen/${DATASETS_DATE["medgen"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/medgen'
add_load_list ${LOAD_DATA_BASE}/virtuoso/mesh/${DATASETS_DATE["mesh"]}  '*.nt.gz' 'http://togovar.biosciencedbc.jp/mesh'
add_load_list ${LOAD_DATA_BASE}/virtuoso/mondo/${DATASETS_DATE["mondo"]} '*.owl' 'http://togovar.biosciencedbc.jp/mondo'
add_load_list ${LOAD_DATA_BASE}/virtuoso/nlm-catalog/${DATASETS_DATE["nlm-catalog"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/nlm-catalog'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubmed/${DATASETS_DATE["pubmed"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/pubmed'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubtator/${DATASETS_DATE["pubtator"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/pubtator'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubcasefinder/20191005/graph-1/data  '*.ttl.gz' 'http://togovar.biosciencedbc.jp/pubcasefinder'
add_load_list ${LOAD_DATA_BASE}/virtuoso/so/${DATASETS_DATE["so"]} '*.owl' 'http://togovar.biosciencedbc.jp/so'
add_load_list ${LOAD_DATA_BASE}/virtuoso/go/${DATASETS_DATE["go"]} '*.owl' 'http://togovar.biosciencedbc.jp/go'
add_load_list ${LOAD_DATA_BASE}/virtuoso/ensembl_grch38/${DATASETS_DATE["ensembl_grch38"]}  '*.ttl' 'http://togovar.biosciencedbc.jp/ensembl38'
add_load_list ${LOAD_DATA_BASE}/virtuoso/STY/20210201 '*.ttl' 'http://togovar.biosciencedbc.jp/sty'
add_load_list ${LOAD_DATA_BASE}/virtuoso/HPO/20210217 '*.owl' 'http://togovar.biosciencedbc.jp/hpo'
#add_load_list ${LOAD_DATA_BASE}/virtuoso/colil/20190528 '*.nt.gz' 'http://togovar.biosciencedbc.jp/colil'
add_load_list ${LOAD_DATA_BASE}/virtuoso/gwas-catalog/study_sample_annotation '*.ttl' 'http://togovar.biosciencedbc.jp/gwas-catalog'
add_load_list ${LOAD_DATA_BASE}/virtuoso/hancestro '*.owl' 'http://togovar.biosciencedbc.jp/hancestro'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pato '*.owl' 'http://togovar.biosciencedbc.jp/pato'

#echo
#echo  "Files to be loaded"
#echo

# ロード対象ファイル一覧の出力
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="SELECT ll_file, ll_graph FROM DB.DBA.LOAD_LIST where ll_state = 0;" > /load_list.log

cat /load_list.log

# ロード対象ファイル一覧から対象データセットのうちファイルが一ファイルもない場合エラーログを出力して終了

ERRORLOG_NOTEXIST=()
for dataset in ${DATASETS[@]}; do
  load_file_count=`cat /load_list.log | grep "${dataset}" | wc -l`
  if [ ${load_file_count} -eq 0 ]; then
    ERRORLOG_NOTEXIST=("${ERRORLOG_NOTEXIST[@]}" "${dataset}のロード対象ファイルがありません")
  fi
done

if [ ${#ERRORLOG_NOTEXIST[@]} -ge 1 ]; then
  for errorlog in ${ERRORLOG_NOTEXIST[@]}; do
    echo "${errorlog}" >&2
  done
  exit 1
fi	


# ロードの実行
pids=()
for i in $(seq 1 ${PARALLEL}); do
  ${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="rdf_loader_run();" &
  pids[$!]=$!
done

wait ${pids[@]}

# checkpoint の発行
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="checkpoint;"


# エラー一覧を表示
${ISQL} -H ${HOST} -S ${PORT} -U ${USER} -P ${PASSWORD} VERBOSE=OFF BANNER=OFF EXEC="SELECT * FROM DB.DBA.LOAD_LIST WHERE ll_error IS NOT NULL;" > /error.log

if [ -s /error.log ]; then
  echo "ロード時にエラーが発生しました" >&2
  cat /error.log >&2
  exit 1
fi

# ロードした7つの対象データセットの更新日をファイルに出力
DATE_FILE=/data/dataset_date.tsv
touch ${DATE_FILE}

for dataset in ${!DATASETS_DATE[@]}; do
  echo -e "${dataset}\t${DATASETS_DATE[$dataset]}">> ${DATE_FILE}
done

now=`date "+%Y%m%d-%H%M%S"`
echo "Finished load.sh at $now"

