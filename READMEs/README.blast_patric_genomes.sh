# This README describes the entire workflow for searching
# kmers against the PATRIC genomes and the PATRIC genes.
# Searching against the genomes should be sufficient to
# investigate the uniqueness of a kmer, however searching
# against the PATRIC genes provides functional insights into
# what a particular kmer is matching.

# Transfer the patric genomes to a cluster. The patric genomes
# are available at a public ftp site. This site is slow. 
# (ftp://ftp.patricbrc.org/genomes/)
rsync -arv --include '*.fna' --include '*/' --exclude '*' \
  /vol/patric3/downloads/genomes/                         \
  bebop.lcrc.anl.gov:/blues/gpfs/globalscratch/brettin/genomes

# Create a file with a list of all the genomes
find ./genomes -name "*.fna" > genomes.list

# Create a blast database for each genome. The first argument,
# 72, is the number of parallel instances of the blast. A
# recemt run on 220K genomes took 10:51:10 - 10:19:38.
# makeblastdb command that is executed.
makeblastdb.sh 72 genomes.list


# Get rid of genomes for which the .fna makeblastdb failed.
# Some genomes will fail to make a blast database because they
# lack sequences. These genomes will be the large eukaryotic
# genomes that are included in PATRIC.
find genomes -name "*nin" | perl -lne 'print if /.fna.nin$/' > nin
for n in $(cat nin) ; do d=$(dirname $n) ; b=$(basename $n ".nin") ; echo $d/$b ; done > genomes.list
rm nin

# Set up blast jobs
split -l 20000 genomes.list genomes.list
wc genomes.list*
rm genomes.list


# run blast jobs (currently, we're running 9 jobs in parallel,
# each allocated to 3 cores, on each node. At this load, the
# top command is showing the cpu resources being underutilized.
# it is a conservative approach to not overloading I/O though.
# this particular run configuration with 20000 genomes per
# input runs in about 47 minutes on bebop.
for n in genomes.list* ; do qsub -v ARG1=$HOME/PATRIC/brettin/global_survey/brettin/allen/mcs.unique.60.fa,ARG2=$n $HOME/PATRIC/brettin/global_survey/bin/qsub_blastn.sh ; sleep 1 ; done


# create a file with a list of all the gene ffn files
ls genes > genes.dirs 
perl -lne 'print "genes/", $_, "/", $_, ".PATRIC.ffn"' genes.dirs > genes.list
rm genes.dirs
wc genes.list

# create a database for each gene file
# this can be done on the head node with 36 cores
# it takes about 4 minutes to do 20,000 on bebop
# this assumes 72 jobs in parallel, then we can
# extrapolate 40 minutes to do 200,000 genome gene sets.
makeblastdb.sh 72 genes.list

# get rid of genes for which makeblastdb failed on the .ffn file
find genes -name "*ffn" | perl -lne 'print if /.PATRIC.ffn$/' > ffn
find genes -name "*nin" | perl -lne 'print if /.PATRIC.ffn.nin$/' > nin
for n in $(cat ffn) ; do basename $n ; done > tmp.1
for n in $(cat nin) ; do basename $n ".nin" ; done > tmp.2
cat tmp.1 tmp.2 | sort | uniq -u
rm tmp.1 tmp.2


# do the blastn runs
for n in genomes.list* ; do qsub -v ARG1=$HOME/PATRIC/brettin/global_survey/brettin/allen/mcs.unique.60.fa,ARG2=$n $HOME/PATRIC/brettin/global_survey/bin/qsub_blastn.sh ; sleep 1 ; done
