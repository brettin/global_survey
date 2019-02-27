#!/bin/bash
#SBATCH -A PATRIC
#SBATCH -t 8:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=12
#SBATCH --partition=bdwd

# qsub_assembly.sh

# This is used to run one job on n metagenomes.
# The n metagenomes are listed in an input file.
# Execute using qsub -v ARG1=<val>
echo $ARG1

PATH=/lcrc/project/PATRIC/brettin/global_survey/bin:$PATH
PATH=/lcrc/project/PATRIC/anaconda3/bin/$PATH

. /lcrc/project/PATRIC/anaconda3/etc/profile.d/conda.sh
CONDA="base"
conda activate $CONDA
which perl
which python
date

dir=$(pwd -P)
echo "working dir: $dir"

outdir=$dir/$SLURM_JOBID
mkdir -p $outdir

perl /lcrc/project/PATRIC/brettin/global_survey/bin/plasmid_read_assembly.pl $ARG1 $outdir

# tmpdir=/scratch/$SLURM_JOBID
# mkdir -p $tmpdir

# perl /lcrc/project/PATRIC/brettin/global_survey/bin/plasmid_read_assembly.pl $ARG1 $tmpdir

# mv $tmpdir/* $dir/
# rm -r $tmpdir

conda deactivate
