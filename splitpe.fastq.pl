#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

####################Read files#########################
unless (@ARGV == 3) {die "Usage:perl scriptname readfile outfile1 outfile2\n";}

my $inputfile1 = shift;
my $outfile1 = shift;
my $outfile2 = shift;

my $readcount;
my $printreadcount = 0;
my $line;
my $linenr = 0;


open(IN, $inputfile1) or die("Cannot open file\n");
open(OUT, ">$outfile1") or die("Cannot create file\n");
open(OUT2, ">$outfile2") or die("Cannot create file\n");

print "Splitting reads into 2 files..\n";
while ( $line = <IN> ) {
	chomp $line;
	if ($printreadcount == 1000000) {
		$printreadcount = 0;
		print "$readcount PE reads split\n";
	}
	$linenr++;
	if ($linenr == 1){		
		print OUT "$line\n";		
		$readcount++;
		$printreadcount++;
	}
	if ($linenr == 2 ){		
		print OUT "$line\n";
	}
	if ($linenr == 3 ){		
		print OUT "$line\n";
	}	
	if ($linenr == 4){
		print OUT "$line\n";
	}
	if ($linenr == 5){		
		print OUT2 "$line\n";		
	}
	if ($linenr == 6 ){		
		print OUT2 "$line\n";
	}
	if ($linenr == 7 ){		
		print OUT2 "$line\n";
	}	
	if ($linenr == 8){
		print OUT2 "$line\n";
		$linenr =0;
	}	
}

print "done..\n";

close IN;
close OUT;
close OUT2;

exit;