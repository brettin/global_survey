#!/bin/bash
prefix=${1:-tmp}

for n in `find . -name "*split*"` ; do \
  b=$(basename $n) ;           \
  d=$(dirname $n) ;            \
  echo "pushd $d && gzip $b && popd" ; \
done > $prefix.bigfiles-gzip.sh
