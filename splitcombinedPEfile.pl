#!/usr/bin/perl
use warnings;
use strict;
#use diagnostics;

unless (@ARGV == 3) {die "Usage: infile minlength maxlength\n";}

my $inputfile = shift;
my $minlength = shift;
my $maxlength = shift;
my $lib;
my $plib;
my $readnr = 0;
my $preadnr = 0;
my $seq = 0;
my $pseq = 0;
my $pseqprint = 1;
my $name = 0;
my $pname = 0;
my $singleshort = 0;
my $penr;
my %read1all;
my %read1p;
my %read2all;
my %read2p;
my $status = 0;
my $allreads = 0;
my @splitline;
	
open(IN, $inputfile) or die;
open(OUTp, ">paired.fa") or die;
open(OUTs, ">single.fa") or die;
open(OUTstats, ">stats.txt") or die;

$lib = 0;

while (my $line = <IN>)  {	
		if ($line =~ m/>/ ) {				
			$line =~ s/No_name/0_0_$allreads/g; 		
			$pname = $name;
			$name = $line;		
			chomp $line;			
			@splitline = split(/_/, $line);  
			$plib = $lib;
			$preadnr = $readnr;				
			$lib = $splitline[0];
			$lib =~ s/>//g; 		
			$readnr = $splitline[2];
			$penr = $splitline[1];
			$allreads++;
			$status++;
			if ($status == 1000000) {
				print "$allreads done\n";
				$status = 0;
			}
		}		
		else {
			$pseq = $seq;
			$seq = $line;
		if ($penr == 1){
			$read1all{length($seq)-1}++;
		}
		else {
			$read2all{length($seq)-1}++;
		}
			if (length($seq) > $maxlength+1) {		
				$seq = substr($seq,0,$maxlength)."\n";				
			}			
			if ($lib == $plib and $readnr == $preadnr) {			
				if (length($pseq) < $minlength or length($seq) < $minlength) {
					if (length($pseq) < $minlength) {
						$singleshort++;			
					}
					else {
						print OUTs $pname;
						print OUTs $pseq;
					}				
					if (length($seq) < $minlength) {
						$singleshort++;			
					}
					else {
						print OUTs $name;
						print OUTs $seq;
					}	
				}
				else {
					print OUTp $pname;
					print OUTp $pseq;
					print OUTp $name;
					print OUTp $seq;
					if ($penr == 1){
						$read1p{length($seq)-1}++;
						$read2p{length($pseq)-1}++;
					}
					else {
						$read1p{length($pseq)-1}++;
						$read2p{length($seq)-1}++;
					}
				}
				$pseqprint = 1;
			}	
			else {
				if ($pseqprint == 0) {				
					if (length($pseq) < $minlength) {
						$singleshort++;			
					}
					else {
						print OUTs $pname;
						print OUTs $pseq;
					}
				}
				$pseqprint = 0;
			}
		}
	}
	
print OUTstats "$singleshort single reads below $minlength\n";

print OUTstats "Read 1 length distribution\n";
my @dist1all = sort(keys%read1all);
my $totalreads = 0;
my $PEreads = 0;
foreach my $name (@dist1all) {
	print OUTstats "$name\t$read1all{$name}\n";
	$totalreads = $totalreads + $read1all{$name};
}

print OUTstats "Read 2 length distribution\n";
my @dist2all = sort(keys%read2all);
foreach my $name (@dist2all) {
	print OUTstats "$name\t$read2all{$name}\n";
	$totalreads = $totalreads + $read2all{$name};
}

print OUTstats "Read 1 paired length distribution\n";
my @dist1p = sort(keys%read1p);
foreach my $name (@dist1p) {
	print OUTstats "$name\t$read1p{$name}\n";
	$PEreads = $PEreads + $read1p{$name};	
}
print OUTstats "Read 2 paired length distribution\n";
my @dist2p = sort(keys%read2p);
foreach my $name (@dist2p) {
	print OUTstats "$name\t$read2p{$name}\n";
	$PEreads = $PEreads + $read2p{$name};	
}

print "$totalreads reads in the original file\n";
print $totalreads-$singleshort," reads after trim\n";
print "$singleshort reads discarded\n";
print "$PEreads reads kept as PE\n";
print $totalreads-$PEreads-$singleshort," single reads\n";

close IN;
close OUTp;
close OUTs;
close OUTstats;
exit;