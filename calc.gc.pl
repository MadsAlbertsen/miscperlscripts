#!/usr/bin/perl
use warnings;
use strict;

unless (@ARGV == 2) {die "Usage:  infile outfile\n";}

my $inputfile = shift;
my $outfile = shift;

my %counts;
my $seq2;
my @array;
my $dummy = 0;
	
open(IN, $inputfile) or die;
open(IN, ">$outfile") or die;


while (my $line = <IN>)  {
	if ($line =~ m/>/) {
		chomp $line;
		if ($dummy == 1){
			push (@array, "$seq2");	
		}
		$seq2 = "$line\t";
		$dummy =1;
	}
	else {
		chomp $line;
		$seq2 = $seq2.$line;
		}
}
push (@array, "$seq2");	          #to catch the last sequence

foreach my $sequence (@array){
	$counts{G} = 0;
	$counts{C} = 0;
	$counts{A} = 0;
	$counts{T} = 0;
	my @tseq = split("\t", $sequence);
	my @seq = split("", $tseq[1]);
	foreach my $nucleotide (@seq) {
			$counts{$nucleotide}++;
		}
	my $gc = ($counts{G}+$counts{C})/($counts{G}+$counts{C}+$counts{A}+$counts{T})*100;
	print OUT "$tseq[0]\t$gc\n";
}

close IN;
exit;