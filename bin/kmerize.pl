#!/bin/env perl

while(<>) {
  chomp;
  if (/^>/) {
    if (defined $last) {
      print_kmers($last, $string);
      undef $string;
    }
    $last = $_;
  }
  else {
    $string .= $_;
  }
}

sub print_kmers {
  use strict;
  my $def = $_[0];
  my $string = $_[1];

  my @arr = split //, $string;
  my $size = scalar(@arr);

  for (my $n=-60; $n<$size-60; $n++) {
    print ">", $def, ".", $n, "\n", join('', @arr[$n .. $n+59]), "\n";
  }
}
