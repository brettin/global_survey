#!/bin/bash
set -x
set -e

# METHODS

# The general pattern for running the searches on a cluster involves
# passing the query and subject filenames into the qsub script by way
# of environment variables.

# The query file is fixed, as it is the MCS kmers. The subject file is
# provided from a file that contains a list of filenames.

# The database file size varies. Part of the preprocessing of database
# files involves splitting big files so that the memory limits of the
# compute nodes are not exceeded.

BASE=/blues/gpfs/globalscratch/brettin/
# This is the directory where the fastq files live
export DATA=$BASE/permafrost
# This is a directormy where results and temporary files will be written
export MCS=$BASE/permafrost_mcs

cd $DATA

/home/brettin/PATRIC/brettin/global_survey/bin/split_bigfiles.sh
echo "parallel -j 16 {} :::: tmp.bigfiles.sh" > bigfiles.parallel
chmod u+x bigfiles.parallel 
./bigfiles.parallel > bigfiles.log 2>&1

/home/brettin/PATRIC/brettin/global_survey/bin/gzip_split_bigfiles.sh
echo "parallel -j 16 {} :::: tmp.bigfiles-gzip.sh" > bigfiles.gzip.parallel
chmod u+x bigfiles.gzip.parallel
./bigfiles.gzip.parallel &

find . -size +8G -not -name "*split*" -exec rm {} \;

cd ../
mkdir -p $MCS
cd $MCS

# Running the search involves creating the subject file. This can be
# done easily with the find and split commands.

find $DATA  -not -path '*/\.*' -type f \( -iname \*.fastq.gz -o -iname \*.fa.gz -o -iname \*.fas.gz -o -iname \*fasta.gz -o -iname \*fna.gz -o -iname \*fq.gz -o -iname \*split\* \) > subjects_file

# This fails to produce input if there are not at least 40 lines in subjects_file
split -l 40 subjects_file subjects_file 
wc subjects_file*
rm subjects_file


for n in subjects_file* ; do echo $n ; sbatch --export ARG1=/lcrc/project/PATRIC/brettin/global_survey/brettin/allen/mcs.unique.60.fa,ARG2=$n /lcrc/project/PATRIC/brettin/global_survey/bin/sbatch_vsearch.sh ; sleep 1 ; done > sbatch.log

# It is good to check for errors in the log files. A simple case
# insensitive grep for error in the log files should work. Any errors
# that are found are investigated manually and jobs are rurun if
# necessary.

grep -i error slurm-*.out
