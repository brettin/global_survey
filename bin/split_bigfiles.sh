#!/bin/bash

# assumes you want to run in the . directrory

prefix=${1:-tmp}

find . -size +8G -name "*.fastq.gz" > $prefix.bigfiles.fastqgz
find . -size +8G -name "*.fq.gz"    > $prefix.bigfiles.fqgz
find . -size +8G -name "*.fa.gz"    > $prefix.bigfiles.fagz
find . -size +8G -name "*.fas.gz"   > $prefix.bigfiles.fasgz
find . -size +8G -name "*.fasta.gz" > $prefix.bigfiles.fastagz
find . -size +8G -name "*.fna.gz"   > $prefix.bigfiles.fnagz

for n in `cat $prefix.bigfiles.*` ; do   \
  b=$(basename $n) ;           \
  d=$(dirname $n) ;            \
  p=$(basename $b ".gz") ;     \
  echo "pushd $d && zcat $b | split -d -l 200000000 - $p.split && popd" ; \
done > $prefix.bigfiles.sh

