#!/bin/env perl

while(<>){
  chomp;
  if (/^>/) {
    $defline = $_;
  }
  else {
    $seq = $_;
    if (exists $h{$seq}) {
      $h{$seq} .= ",$defline";
    }
    else {
      $h{$seq} = $defline;
    }
    undef $defline;
    undef $seq;
  }
}

foreach my $seq (keys %h) {
  print $h{$seq}, "\n", $seq, "\n";
}
