#!/usr/bin/env bash

# usage arg1=query, arg2=db
# log filecreated

export PATH=$HOME/vagrant_builds/vagrant_blast/ncbi-blast-2.7.1+/bin:$PATH
export PATH=$HOME/local/bin:$PATH
export PATH=$HOME/seqtk:$PATH
echo "slurm job id: $SLURM_JOBID"
echo "slurm node id: $SLURM_NODEID"

SLURM_JOBID=${SLURM_JOBID:-0}
HOST="$( hostname )"
USER="$( whoami )"

base=$(basename $0 ".sh")
echo "base: $base"
echo "pid: $$"

# blastn.sh args: $qry $db $tmpdir
qry=$1
db=$2
out=$3

echo "db: $db"
echo "qry: $qry"
echo "out: $out"

qry_base=$(basename $qry)
db_base=$(basename $db)

echo "mkdir -p $out"
mkdir -p $out
ls -l $out

top -b -n 600 -d 10 -u $USER > $SLURM_JOBID.$HOST.$$.top &
cpid=$!


echo "START: " `date`

# if db is file of filenames:
# parallel -j 9 "blastn -db {} -query $qry -out $out/$qry_base.{/.}.blastn.$SLURM_JOBID -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 3 -max_hsps 100 -outfmt 6" :::: $db

# if qry is file of filenames:
# recommend using 
# -max_target_seqs 10000
# -word_size 30
# -dust no -soft_masking false

echo "executing: "
#parallel --dry-run "blastn -max_target_seqs 100000 -word_size 30 -dust no -soft_masking false -db $db -query {} -out $out/$db_base.{/}.blastn.$SLURM_JOBID -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 8 -outfmt 6" :::: $qry
# This is for running PATRIC genomes against a kmer database

#parallel -j 4 "blastn -max_target_seqs 100000 -word_size 30 -dust no -soft_masking false -db $db -query {} -out $out/$db_base.{/}.blastn.$SLURM_JOBID -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 8 -outfmt 6" :::: $qry

# This modification was added so that gzip'd fastq files (qry) could be searched against the Addgene kmers (db)
# This script runs on a node. It uses parallel to launch 9 blastn instances, each getting 4 cores (-num_threads 4).
# Each instance of blastn is given a query file name from a file of filenames. So, ideally each file of filenames
# would contain some multiple of 9 files.
parallel --dry-run "zcat {} | seqtk seq -A - | blastn -query - -db $db -max_target_seqs 10000 -word_size 30 -dust no -soft_masking false -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 4 -outfmt 6 | gzip -c  >  $out/$db_base.{/}.blastn.$SLURM_JOBID.out.gz" :::: $qry

parallel -j 9 "zcat {} | seqtk seq -A - | blastn -query - -db $db -max_target_seqs 10000 -word_size 30 -dust no -soft_masking false -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 4 -outfmt 6 | gzip -c  >  $out/$db_base.{/}.blastn.$SLURM_JOBID.out.gz" :::: $qry

echo "STOP: " `date`


kill -9 $cpid
export PATH=$HOME/seqtk:$PATH
