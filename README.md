
plasmid_read_assembly.py takes in 3 or 4 files:
	- fasta file of starting kmers/sequences
	- read file 1 (read files must be fasta format)
	- base output name (two output files are created: out_name.fa
	  contains the assembled contigs and out_name.cov has a list of
	  coverage for each kmer and gives output if the assembly stops due
      to a repeat region or diverging sequence.
	- command line option -p for a paired-read file

in this order:
   python plasmid_read_assembly.py start_seq_SRR3984929.txt \ 
                                   SRR3984929_1_short.fasta \
                                   SRR3984929_assembly      \
                                   -p=SRR3984929_2_short.fasta

The --help command will also give the command-line arguments. There are
two other optional arguments (kmer length and minimum coverage) but the
defaults should be fine.

The file all_start_seq.tbl has 4 tab-separated columns with read file 1,
read file 2 (blank if not a paired file), kmer ID, and kmer sequence for
all samples with MCS kmer hits. The kmer sequence is included because
some samples only have matches with a single insertion or mismatch, so
these were taken from the target sequences.


