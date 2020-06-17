# RDF化対象のデータセット名
DATASET=so

# global.confを読み込む
SCRIPT_DIR="$(cd $(dirname $0); pwd)"
source "${SCRIPT_DIR}/global.conf"

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
wget -c -nd -N https://raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/Ontology_Files/so.owl 2> stdout.log
