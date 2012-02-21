#!/usr/bin/perl

use warnings;
use strict;
#use diagnostics;

####################Read files#########################
unless (@ARGV == 2) {die "Usage:  scriptname mannotaterfile outfile \n";}

my $inputfile = shift;
my $outfile = shift;

open(IN, $inputfile) or die("Cannot open file\n");
open(OUT, ">$outfile") or die("Cannot create $outfile file\n");

my $line;
my $count;
my @splitline1;
my @splitline2;
my @splitline3;
my @splitline4;
my @splitline5;
my %cats;


################### Read categories into HASH (yeps reads the whole file... in order to make it generic..)
while ( $line = <IN> ) {
	chomp $line;	
	$count++;
	if ($count > 1){
		@splitline1 = split(/\t/,$line);
		@splitline2 = split(/;/,$splitline1[8]);                      #where the extra splits are! = not generic afterall..
		foreach my $id (@splitline2){
			@splitline3 = split(/=/,$id);
			$cats{$splitline3[0]} = "";
			if ($splitline3[0] eq "Ontology_term"){				
				@splitline4 = split(/ /,$splitline3[1]);				
				foreach my $id1 (@splitline4){
					@splitline5 = split(/:/,$id1);
					$cats{$splitline5[0]} = "";
				}
			}
		}
	}
}
my @outcats1 = keys %cats;
my $outstring = join("\t",@outcats1);
print OUT "Contig\tGenecaller\tCDS\tstart\tend\trandom1\tstrand\trandom2\t$outstring\n";	

seek (IN,0,0);


$count = 0;
while ( $line = <IN> ) {
	chomp $line;	
	$count++;
	if ($count > 1){
		@splitline1 = split(/\t/,$line);
		@splitline2 = split(/;/,$splitline1[8]); #where the extra splits are!
		foreach my $id (@splitline2){
			@splitline3 = split(/=/,$id);
			$cats{$splitline3[0]} = $splitline3[1];
			if ($splitline3[0] eq "Ontology_term"){
				@splitline4 = split(/ /,$splitline3[1]);
				foreach my $id1 (@splitline4){
					@splitline5 = split(/:/,$id1);
					$cats{$splitline5[0]} = $id1;					
				}
			}
		}
		my @outcats = keys %cats;
		pop @splitline1; #remove the ; seperated field
		foreach my $tempout (@outcats){
			push (@splitline1, $cats{$tempout}); #should add an empty field if not 	
			$cats{$tempout} = "";
		}	
		my $outstring = join("\t",@splitline1);
		print OUT "$outstring\n";		
	}
}





print "done.\n";

close IN;
close OUT;

exit;