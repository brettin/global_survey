# This README describes how to find kmers inside a fasta file
# that are duplicates and merge them into a single fasta
# record in a new fasta file. When merging two fasta records
# that have the same kmer sequence, the definition line of
# each fasta record is joined into a single definition line
# for the new fasta record.

# create the kmer files, assumes one fasta record per vector,
# and multiple fasta records (vectors) per input file.
kmerize.pl < Addgene_plasmids_min60.fa > Addgene_plasmids_min60.kmers.60

# transfer addgene kmer set to bebop
cd /vol/global_survey/danton/plasmid_databases
rsync -arv addgene_popular_top10 bebop.lcrc.anl.gov:scratch/

# concatenate all addgene kmers into a single query file
# and then de-duplicate the fasta records.
cd /blues/gpfs/globalscratch/brettin/global_survey
cat *.kmer.fna > addgene_popular_top10.fna

# dedup_kmers.pl
# read each fasta record, the key is the hash, the value is the defline
# if the hash already exists, append ,defline to the value
perl ../../../dedup_kmers.pl addgene_popular_top10.fna > addgene_popular_top10.unique.fna

# perform search against metagenomes using addgene_popular_top19.fna as query
# and metagenomes as da_kmers
