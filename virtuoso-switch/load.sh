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

sleep 60

now=`date "+%Y%m%d-%H%M%S"`
echo "Started load.sh at $now"

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

add_load_list ${LOAD_DATA_BASE}/virtuoso/clinvar/latest '*.ttl.gz' 'http://togovar.biosciencedbc.jp/clinvar'
add_load_list ${LOAD_DATA_BASE}/virtuoso/ensembl/latest  '*.ttl' 'http://togovar.biosciencedbc.jp/ensembl37'
add_load_list ${LOAD_DATA_BASE}/virtuoso/gwas-catalog/ '*' 'http://togovar.biosciencedbc.jp/gwas-catalog'
add_load_list ${LOAD_DATA_BASE}/virtuoso/efo/20201110/ 'efo.owl' 'http://togovar.biosciencedbc.jp/efo'
add_load_list ${LOAD_DATA_BASE}/virtuoso/hco/20180409 '*.ttl' 'http://togovar.biosciencedbc.jp/hco'
add_load_list ${LOAD_DATA_BASE}/virtuoso/hgnc/latest '*.ttl' 'http://togovar.biosciencedbc.jp/hgnc'
add_load_list ${LOAD_DATA_BASE}/virtuoso/medgen/latest  '*.ttl' 'http://togovar.biosciencedbc.jp/medgen'
add_load_list ${LOAD_DATA_BASE}/virtuoso/mesh/20201123  '*.nt.gz' 'http://togovar.biosciencedbc.jp/mesh'
add_load_list ${LOAD_DATA_BASE}/virtuoso/mondo/20201123  '*.owl' 'http://togovar.biosciencedbc.jp/mondo'
add_load_list ${LOAD_DATA_BASE}/virtuoso/nlm-catalog/latest  '*.ttl' 'http://togovar.biosciencedbc.jp/nlm-catalog'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubmed/latest  '*.ttl' 'http://togovar.biosciencedbc.jp/pubmed'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubtator/latest  '*.ttl' 'http://togovar.biosciencedbc.jp/pubtator'
add_load_list ${LOAD_DATA_BASE}/virtuoso/pubcasefinder/20191005/graph-1/data  '*.ttl.gz' 'http://togovar.biosciencedbc.jp/pubcasefinder'
add_load_list ${LOAD_DATA_BASE}/virtuoso/so/20190301 '*.owl' 'http://togovar.biosciencedbc.jp/so'
add_load_list ${LOAD_DATA_BASE}/virtuoso/ensembl38/20201012  '*.ttl' 'http://togovar.biosciencedbc.jp/ensembl38'
add_load_list ${LOAD_DATA_BASE}/virtuoso/STY/20210201 '*.ttl' 'http://togovar.biosciencedbc.jp/sty'
add_load_list ${LOAD_DATA_BASE}/virtuoso/HPO/20210217 '*.owl' 'http://togovar.biosciencedbc.jp/hpo'
#add_load_list ${LOAD_DATA_BASE}/virtuoso/colil/20190528 '*.nt.gz' 'http://togovar.biosciencedbc.jp/colil'



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


now=`date "+%Y%m%d-%H%M%S"`
echo "Finished load.sh at $now"
