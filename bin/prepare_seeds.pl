#!/bin/env perl
while(<>){
 chomp;
 @a=split/\t/; 
 print "$a[2]\n$a[3]\n";
}
