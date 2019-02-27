# We start with the file provided by Jamie. That file is
# called all_start_seq.tbl. The file is a tab delimited file
# containing in the first column a metagenome read file, in
# the second column the name of the mate pair file, in the
# third column the fasta definition line of the kmer seed, and
# in the fourth column the sequence of the kmer seed. The kmer
# seed can be a kmer from the mcs.unique.60.fa file.

# We parse that file to produce two products. The first is a
# file containing fasta records of the seed kmers grouped by
# metagenome. So, for each metagenome, there is one or more
# fasta records to use as seeds for the assembly.

for n in `cut -f1 all_start_seq.tbl | uniq` ; do echo $n ; \
grep $n all_start_seq.tbl | prepare_seeds.pl > $n.seeds ; done

# The command above will prepare assemby seed files, one for
# each unique metagenome read file name in column 1 of
# all_start_seq.tbl.

# Next, we will prepare the master input file for the qsub
# script. Ultimately, the master input file will be split into
# some number of smaller files. This will be discussed later.

prepare_parameters.pl all_start_seq.tbl > assembly_params

# Now that the file containing all the assembly_params has
# been constructed, it can be split into smaller files. The
# purpose of this file is that it contains the parameters for
# each run of the plasmid_read_assembly.py script. A perl
# wrapper of the read_assembly.py reads the paramters file and
# calls the python script passing in the correct parameters.
# Each line in the parameters file provides parameters for one
# invocation of the read_assembly.py script.

split -l 25 assembly_params assembly_params_split
rm assembly_params
for n in assembly_params_split* ; do echo $n ; qsub -v ARG1=$n qsub_assembly.sh ; done

