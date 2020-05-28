# RDF化対象のデータセット名
DATASET=pubcasefinder

# RDFファイルを出力するディレクトリのトップ
OUTDIR=/mnt/share/togovar/load/virtuoso/

# RDFファイルを出力する空ディレクトリを作成する
YYYYMMDD="20191005"
OUTDIR=${OUTDIR}/${DATASET}/${YYYYMMDD}
rm -rf $OUTDIR
mkdir -p $OUTDIR

pushd $OUTDIR
wget https://integbio.jp/rdf/download/pubcasefinder/2019-10-05/all/pubcasefinder.tar.gz 
tar xvfz pubcasefinder.tar.gz
popd
