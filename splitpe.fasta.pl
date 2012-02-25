#!/usr/bin/perl
use warnings;
use strict;

unless (@ARGV == 1) {die "Usage: infile\n";}

my $inputfile = shift;
my $line;
my $header;
my $prevheader;
my $count = 0;
my $seq;
	
open(IN, $inputfile) or die;
open(OUTp1, ">p1.fa") or die;
open(OUTp2, ">p2.fa") or die;


while (my $line = <IN>)  {	
	chomp $line;
	if ($line =~ m/>/) {
		$header = $line;
		if ($count == 1){
			print OUTp1 "$prevheader\n";
			print OUTp1 "$seq\n";			
		}
		if ($count == 2){
			print OUTp2 "$prevheader\n";
			print OUTp2 "$seq\n";			
			$count = 0;
		}
		$count++;
		$seq = "";
		$prevheader = $header;		
	}
	else{
		$seq = $seq.$line;
	}
}

print OUTp2 "$prevheader\n";
print OUTp2 "$seq\n";			

close IN;
close OUTp1;
close OUTp2;

exit;