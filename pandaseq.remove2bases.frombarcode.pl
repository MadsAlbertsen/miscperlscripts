#!/usr/bin/perl

use warnings;
use strict;
#use diagnostics;

####################Read files#########################
unless (@ARGV == 2) {die "Usage:perl scriptname readfile outfile\n";}

my $inputfile1 = shift;
my $outfile1 = shift;

my $readcount;
my $printreadcount = 0;
my $line;
my $linenr = 0;


open(IN, $inputfile1) or die("Cannot open file\n");
open(OUT, ">$outfile1") or die("Cannot create file\n");

print "Stripping 2 nucleotides of the barcode..\n";
while ( $line = <IN> ) {
	chomp $line;
	if ($printreadcount == 1000000) {
		$printreadcount = 0;
		print "$readcount headers corrected\n";
	}
	$linenr++;
	if ($linenr == 1){		
		$line = substr($line,0,length($line)-2);
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
		$linenr = 0;
		print OUT "$line\n";
	}
}

print "done..\n"

close IN;
close OUT;

exit;