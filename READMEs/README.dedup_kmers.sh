# This README describes how to find kmers inside a fasta file
# that are duplicates and merge them into a single fasta
# record in a new fasta file. When merging two fasta records
# that have the same kmer sequence, the definition line of
# each fasta record is joined into a single definition line
# for the new fasta record.

# create the kmer files, assumes one fasta record per vector,
# and multiple fasta records (vectors) per input file.
kmerize.pl < Addgene_plasmids_min60.fa > Addgene_plasmids_min60.kmers.6.fa

# dedup_kmers.pl
# read each fasta record, the key is the hash, the value is the defline
# if the hash already exists, append ,defline to the value
dedup_kmers.pl Addgene_plasmids_min60.kmers.60.fa > Addgene_plasmids_min60.kmers.60.uniq.fa

