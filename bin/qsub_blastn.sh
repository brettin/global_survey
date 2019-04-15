#!/bin/bash

#SBATCH -A GENENG-IND 
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=bdwall

# This is used to run one job on n files.
# The n files are listed in an input file.
# ARG 1 is the fasta query file.
# ARG 2 is the input file of file names that serve as
# databases in the search.
# Execute using qsub -v ARG1=<val>,ARG2=<val>

export PATH=$PATH:/lcrc/project/PATRIC/brettin/global_survey/bin

echo "ARG1 should be the query"
echo "ARG2 should be the database (each PATRIC genome ie)"

echo "ARG1: $ARG1"
echo "ARG2: $ARG2"

which blastn.sh

dir=$(pwd)
echo "working dir: $dir"

tmpdir=/scratch/$SLURM_JOBID
mkdir -p $tmpdir

qry=$ARG1
db=$ARG2

blastn.sh $qry $db $tmpdir

find $tmpdir/ -type f -size 0 -delete
mkdir -p $dir/$SLURM_JOBID
mv $tmpdir/* $dir/$SLURM_JOBID/

