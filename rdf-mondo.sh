# RDF化対象のデータセット名
DATASET=mondo

# RDFファイルを出力するディレクトリのトップ
OUTDIR=/mnt/share/togovar/load/virtuoso/

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD=`LANG=C; date +%Y%m%d`
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
wget http://purl.obolibrary.org/obo/mondo.owl
popd
