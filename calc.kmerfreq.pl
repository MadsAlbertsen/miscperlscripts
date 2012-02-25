#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;


unless (@ARGV == 4) {die "Usage:perl scriptname fastafile outfile minsequencelength kmerlength\n";}

my $inputfile1 = shift;
my $outfile = shift;
my $minlength = shift;
my $kmerlength = shift;
my $line;
my @probes;
my @kmerheader;
my %kmer;
my $count = -1;
my $printreadcount = 0;
my $seqcount = 0;
my $seqcountgood = 0;
my $kmerlengthprobe;
my $header;
my $sequence;
my $totalkmers = 0;
my $output = "Contig";

####################Read files#########################
open(IN, $inputfile1) or die("Cannot open file\n");
open(OUT, ">$outfile") or die("Cannot create file\n");


#Create all possible tetramers

for (my $count2 = 0; $count2 < $kmerlength; $count2++)  {
	$kmerlengthprobe = $kmerlengthprobe."N";
}

push (@probes,$kmerlengthprobe);

foreach my $probe (@probes){
	if ($probe =~ m/N/) { 								# X or N = A, C or T
		my $temp1 = $probe;
		$temp1 =~ s/N/A/;											
		push (@probes, "$temp1");						
		$temp1 = $probe;
		$temp1 =~ s/N/T/;											
		push (@probes, "$temp1");						
		$temp1 = $probe;
		$temp1 =~ s/N/C/;											
		push (@probes, "$temp1");						
		$temp1 = $probe;
		$temp1 =~ s/N/G/;											
		push (@probes, "$temp1");								
	}				
}

foreach my $probe (@probes){
	if ($probe =~ m/N/) { 	
	}
	else{
		$output = $output."\t$probe";
		push (@kmerheader,$probe);
		$kmer{$probe} = 0;
	}
}
print OUT "$output\n";	

while ( $line = <IN> ) {
	chomp $line;
	$totalkmers = 0;
	$count++;	
	foreach my $probe1 (@kmerheader){                                                                                     #reset kmers
		$kmer{$probe1} = 0;		
	}
	if ($line =~ m/>/) { 	
		if ($minlength <= length($sequence) and $count > 0) {
			for (my $count2 = 0; $count2 < length($sequence); $count2++)  {
				if (exists($kmer{substr($sequence,$count2,$kmerlength)})){                                                    #to escape N's in scaffolds
					$kmer{substr($sequence,$count2,$kmerlength)}++;				
					my $rc = reverse(substr($sequence,$count2,$kmerlength));                                                  #Add reverse complement to escape string bias
					$rc =~ tr/ACGT/TGCA/;		
					$kmer{$rc}++;
					$totalkmers+= 2;
				}
			}
			if ($totalkmers > 0){
				foreach my $probe1 (@kmerheader){				
					my $temp1 = $kmer{$probe1}/$totalkmers;				
					$output = $output."\t$temp1";
				}
			print OUT "$output\n";
			$seqcountgood++;
			}
		}
		$sequence = "";	
		$header = $line;
		$output = $header;						
		$seqcount++;
		$printreadcount++;
		if ($printreadcount == 100) {
			$printreadcount = 0;
			print "$seqcount sequences $seqcountgood \>= $minlength bp\n";
		}
	}	
	else{		
		$sequence = $sequence.$line;
	}
}

####################stupid solution to get the last sequence...

$count++;
$totalkmers = 0;
if ($minlength <= length($sequence)) {
	foreach my $probe1 (@kmerheader){                                                                                    
		$kmer{$probe1} = 0;		
	}
	for (my $count2 = 0; $count2 < length($sequence); $count2++)  {
		if (exists($kmer{substr($sequence,$count2,$kmerlength)})){                                                    
			$kmer{substr($sequence,$count2,$kmerlength)}++;				
			my $rc = reverse(substr($sequence,$count2,$kmerlength));                                                 
			$rc =~ tr/ACGT/TGCA/;		
			$kmer{$rc}++;
			$totalkmers+= 2;
		}
	}
	$output = $header;
	foreach my $probe1 (@kmerheader){
		my $temp1 = $kmer{$probe1}/$totalkmers;
		$output = $output."\t$temp1";
	}
	print OUT "$output\n";	
}


close IN;
close OUT;

exit;