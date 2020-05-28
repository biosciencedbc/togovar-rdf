# RDF化対象のデータセット名
DATASET=pubcasefinder

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD="20191005"
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
wget https://integbio.jp/rdf/download/pubcasefinder/2019-10-05/all/pubcasefinder.tar.gz 
tar xvfz pubcasefinder.tar.gz
popd
