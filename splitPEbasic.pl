#!/usr/bin/perl
use warnings;
use strict;

unless (@ARGV == 1) {die "Usage: infile\n";}

my $inputfile = shift;
my $line;
my $count = 0;
	
open(IN, $inputfile) or die;
open(OUTp1, ">p1.fa") or die;
open(OUTp2, ">p2.fa") or die;


while (my $line = <IN>)  {	
	$count++;
	if ($count == 1 or $count == 2){	
		print OUTp1 $line;
	}
	if ($count == 3){	
		print OUTp2 $line;
	}	
	if ($count == 4){	
		print OUTp2 $line;
		$count = 0;		
	}	
}
close IN;
close OUTp1;
close OUTp2;

exit;