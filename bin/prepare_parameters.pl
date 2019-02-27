#!/bin/env perl

# this creates an input file that is consumed by the perl
# wrapper plasmid_read_assembly.pl. The perl wrapper assumes
# a two or three field record. The first field being the kmer
# seed file name, the second being the fasta or fastq file name, and
# the optional third being the fasta or fastq mate pair file name.

print `date`;
my %unique;

while(<>){
 chomp;
 @a=split/\t/; 

 # a check to ensure we are not repeating params for the same
 # files
 next if $unique{$a[0]};
 $unique{$a[0]} = 1; 

 my $file1 = `find ../danton/ -name $a[0]` if $a[0];
 my $file2 = `find ../danton/ -name $a[1]` if $a[1];
 
 chomp $file1 if defined $file1;
 chomp $file2 if defined $file2; 

 if(defined $file1 and defined $file2) {
  print "$a[0].seeds\t$file1\t$file2\n";
 } elsif (defined $file1) {
  print "$a[0].seeds\t$file1\n";
 }
}


# python plasmid_read_assembly.py start_seq_SRR3984929.txt \ 
#                                    SRR3984929_1_short.fasta \
#                                    SRR3984929_assembly      \
#                                    -p=SRR3984929_2_short.fasta

