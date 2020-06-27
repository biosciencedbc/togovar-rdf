#!/bin/bash

#
# -f オプションはダウンロードサイトに新ファイルがなくてもコンバートする
#
while getopts f OPT
do
  case $OPT in
     f) OPTION="-f" ;;
  esac
done

shift $(($OPTIND - 1))

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
"${SCRIPT_DIR}/run.sh" ${OPTION} medgen 
