# RDF化対象のデータセット名
DATASET=mesh

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
wget ftp://ftp.nlm.nih.gov/online/mesh/rdf/mesh.nt.gz 
popd
