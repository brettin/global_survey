# plasmid_read_assembly.pl
use strict;
use File::Basename;
my $assembler_dir="/lcrc/project/PATRIC/brettin/global_survey/bin";

open F, $ARGV[0] or die "cannot open file $ARGV[0] in $0";
my @suffixlist = qw(.fastq.gz .fastq .fasta.gz .fasta .fq.gz .fq .fa.gz .fa);
while(<F>) {
  chomp;
  my @a = split (/\t+/);
  if(@a==2) {

    print "SETUP: ", `date`;
    my $reads1=basename($a[1]);
    !system("cp $a[1] /scratch/")
      or die "could not copy reads into /scratch/";

    my $file1=basename($a[0], @suffixlist);
    my $file2=basename($a[1], @suffixlist);
    my $outfile = $ARGV[1] . '/' . $file1 . '-' . $file2;

    my $cmd = "python $assembler_dir/plasmid_read_assembly.py $a[0] /scratch/$reads1  $outfile";

    print "exec: $cmd\n";
    print "filesize: ", file_size($a[1]), "\n";
    print "START: ", `date`;
    !system("$cmd")
      or warn "FATAL cound not exec: $cmd\n";
    print "STOP: ", `date`;

    !system("rm /scratch/$reads1")
      or die "can not rm /scratch/$reads1";
    print "TEARDOWN: ", `date`;

  }
  elsif(@a==3) {

    print "SETUP: ", `date`;
    my $reads1=basename($a[1]);
    my $reads2=basename($a[2]);
    !system("cp $a[1] $a[2] /scratch/")
      or die "could not copy reads into /scratch/";

    my $file1=basename($a[0], @suffixlist);
    my $file2=basename($a[1], @suffixlist);
    my $file3=basename($a[2], @suffixlist);
    my $outfile = $ARGV[1] . '/' . $file1 . '-' . $file2 . '-' . $file3;

    my $cmd = "python $assembler_dir/plasmid_read_assembly.py $a[0] /scratch/$reads1  $outfile -p=/scratch/$reads2";

    print "exec: $cmd\n";
    print "filesize: ", file_size($a[1]) + file_size($a[2]), "\n";
    print "START: ", `date`;
    !system("$cmd")
      or warn "FATAL cound not exec: $cmd";
    print "STOP: ", `date`;

    !system("rm /scratch/$reads1 /scratch/$reads2") 
      or die "can not rm /scratch/$reads1 /scratch/$reads2";
    print "TEARDOWN: ", `date`;
  }
  else {
    print "parse error: $_\n";
  }
}

sub file_size {
  return -s $_[0];
}  
