#!/bin/bash

#SBATCH -A PATRIC
#SBATCH -t 16:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=bdwall

# This is used to run one job on n files.
# The n files are listed in an input file.
# ARG 1 is the fasta query file.
# ARG 2 is the input file of file names.
# Execute using qsub -v ARG1=<val>,ARG2=<val>

export PATH=$PATH:/lcrc/project/PATRIC/brettin/global_survey/bin
echo "ARG1: $ARG1"
echo "ARG2: $ARG2"

dir=$(pwd)
echo "working dir: $dir"


tmpdir=/scratch/$SLURM_JOBID
mkdir -p $tmpdir

qry=$ARG1
file=$ARG2

for db in `cat $file` ;  do
    echo "args: $qry $db $tmpdir"
    vsearch.sh $qry $db $tmpdir
done


mv $tmpdir/* $dir/

