#!/usr/bin/env bash

# usage arg1=query, arg2=db
# log filecreated

export PATH=/lcrc/project/PATRIC/brettin/vsearch-2.8.0-linux-x86_64/bin:$PATH

echo "slurm job id: $SLURM_JOBID"
echo "slurm node id: $SLURM_NODEID"

SLURM_JOBID=${SLURM_JOBID:-0}
HOST="$( hostname )"
USER="$( whoami )"

base=$(basename $0 ".sh")
echo "base: $base"
echo "pid: $$"


qry=$1
db=$2
out=$3
echo "db: $db"
echo "qrey: $qry"
echo "out: $out"


qry_base=$(basename $qry)
db_base=$(basename $db)
mkdir -p $out


# top -b -n 600 -d 10 -u $USER > $SLURM_JOBID.$HOST.$$.top &
# cpid=$!


echo "START: " `date`
vsearch --maxaccepts 100 --qmask none --dbmask none --query_cov 1.0 --id 0.98 --usearch_global $qry --db $db --alnout $out/$qry_base.$db_base.vsearch.$SLURM_JOBID
echo "STOP: " `date`


# kill -9 $cpid

