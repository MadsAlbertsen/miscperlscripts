#!/usr/bin/perl

use warnings;
use strict;
#use diagnostics;

####################Read files#########################
unless (@ARGV == 3) {die "Usage:  scriptname mannotaterfile extradatafile outfile \n";}

my $inputfile1 = shift;
my $inputfile2 = shift;
my $outfile = shift;

open(IN1, $inputfile1) or die("Cannot open file\n");
open(IN2, $inputfile2) or die("Cannot open file\n");
open(OUT, ">$outfile") or die("Cannot create $outfile file\n");

my $line;
my $empty;
my $count = 0;
my $count1 = 0;
my $elements;
my @splitline;
my %contig;


################### Read file with new data and hash based on contig nr. must be in the format contigid	DATA	DATA
while ( $line = <IN2> ) {
	$count++;
	chomp $line;
		@splitline = split(/\t/,$line);
		my $ID = $splitline[0];
		shift @splitline;
		$contig{$ID} = join("\t",@splitline);
		$elements = scalar @splitline;	
}

foreach my $temp (@splitline){
	$empty = $empty."\t0";
}

while ( $line = <IN1> ) {
	chomp $line;	
	@splitline = split(/\t/,$line);
	my $ID = $splitline[0];
	if (exists($contig{$ID})){
		print OUT "$line\t$contig{$ID}\n";
	}
	else{
		print OUT "$line$empty\n";
	}
}

print "done.\n";

close IN1;
close IN2;
close OUT;

exit;