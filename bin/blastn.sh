#!/usr/bin/env bash

# usage arg1=query, arg2=db
# log filecreated

export PATH=$HOME/vagrant_builds/vagrant_blast/ncbi-blast-2.7.1+/bin:$PATH
export PATH=$HOME/local/bin:$PATH

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

mkdir -p $out


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
parallel --dry-run "blastn -max_target_seqs 10000 -word_size 30 -dust no -soft_masking false -db $db -query {} -out $out/$db_base.{/.}.blastn.$SLURM_JOBID -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 3 -outfmt 6" :::: $qry

parallel -j 9 "blastn -max_target_seqs 10000 -word_size 30 -dust no -soft_masking false -db $db -query {} -out $out/$db_base.{/.}.blastn.$SLURM_JOBID -perc_identity 0.98 -qcov_hsp_perc 1.0 -num_threads 3 -outfmt 6" :::: $qry


echo "STOP: " `date`


kill -9 $cpid

