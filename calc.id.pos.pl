#!/usr/bin/env perl
###############################################################################
#
#    calc.adjusted.coverage.in.samfile.pl
#
#	 Calculates median coverage in a given SAM file. It assumes that contigs
#    /scaffolds are arranged one after another. E.g. all reads to contig X
#    then next contig.
#    
#    Copyright (C) 2012 Mads Albertsen
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

#pragmas
use strict;
use warnings;

#core Perl modules
use Getopt::Long;

#locally-written modules
BEGIN {
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
}

# get input params
my $global_options = checkParams();

my $inputfile;
my $outputfile;
my $bin;
my $minid;
my $maxid;
my $minreadlength;
my $binsize;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$minid = &overrideDefault(0,'minid');
$maxid = &overrideDefault(38,'maxid');
$bin = &overrideDefault(10000,'bin');
$binsize = &overrideDefault(5,'binsize');
$minreadlength = &overrideDefault(50,'minreadlength');

my $headers = 0;
my $outstr;
my $median;
my $id;
my $halfbin = sprintf("%.0f",$bin/2);
my $bin25th = sprintf("%.0f",$bin/4);
my $bin75th = sprintf("%.0f",$bin/4*3);
my %contigid;
my %coverage;
my %outid;
my %outcov;

######################################################################
# CODE HERE
######################################################################

open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

print "Reading the SAM file\n";

while ( my $line = <IN> ) {
	chomp $line;                                                         												     
	my @splitline = split(/\t/, $line); 	
	if ($headers == 0){
		if ($line =~ m/\@SQ/) {                               										                      #if we are in the contig header area then retrive all contigs/scaffolds and store the name and length in the hash: contig		
			my @contigname = split(/:/, $splitline[1]);                     										      
			my @contiglength = split(/:/, $splitline[2]);																  
			$contigid{$contigname[1]} = $contiglength[1];
		}
		if ($line !~ m/(\@PG|\@HD|\@SQ|\@RG)/) { 
				$headers = 1;
		}
	}
	if ($headers == 1){
		my $readlength = length($splitline[9]);
		if ($readlength >= $minreadlength){
			my $pos = $splitline[3];
			my @mismatch = split(/:/,$splitline[12]);
			$id = $mismatch[-1];
			for (my $countid = $pos; $countid <= ($pos+$readlength); $countid++)  {	
				$coverage{$splitline[2]}{$countid}{$id}++;
			}
		}
	}
}

$outstr = "Contig\tStart\tEnd";
for (my $countid = $minid; $countid <= $maxid; $countid++)  {
	$outstr = "$outstr\tM$countid";	
}

for (my $bincount = $minid; $bincount < $maxid; $bincount += $binsize){
	my $lastbin = 0;
	for (my $bin2 = $bincount; $bin2 < $bincount+$binsize; $bin2++){
		last if ($bin2>$maxid);
		$lastbin = $bin2;
	}
	$outstr = "$outstr\tM$bincount.$lastbin";	
}

print "Printing data to file\n";

print OUT "$outstr\tAverage.Coverage\tMedian.Coverage\t25th.quartile\t75th.quartile\n";        

for (my $countid = $minid; $countid <= $maxid; $countid++)  {
	$outid{$countid} = 0; 	
}
	
foreach my $contig (keys %coverage){
	my $writedata = 0;
	my $start = 1;
	for (my $countpos = 1; $countpos <= $contigid{$contig}; $countpos++)  {
		$outstr = "";
		my $poscov = 0;
		for (my $countid = $minid; $countid <= $maxid; $countid++)  {
			if (exists($coverage{$contig}{$countpos}{$countid})){
				$outid{$countid} += $coverage{$contig}{$countpos}{$countid}; 
				$outcov{$countpos}+= $coverage{$contig}{$countpos}{$countid};
			}
			else{
				$outcov{$countpos}+= 0;
			}
		}
		$writedata++;
		if ((($writedata == $bin) and ($countpos+$bin < $contigid{$contig})) or $countpos == $contigid{$contig}){                       #This ensures that the last bin always inculde the last nucleotides - hence it is up to 2xbin-1 large
			$writedata = 0;			
			for (my $countid = $minid; $countid <= $maxid; $countid++)  {
				$outstr = "$outstr\t$outid{$countid}";						
			}	
			for (my $bincount = $minid; $bincount < $maxid; $bincount += $binsize){
				my $binsum = 0;
				for (my $bin2 = $bincount; $bin2 < $bincount+$binsize; $bin2++){
					last if ($bin2>$maxid);
					$binsum += $outid{$bin2};		
					$outid{$bin2} = 0; 			
				}
				$outstr = "$outstr\t$binsum";	
			}
			my $sumcov = 0;
			my $medcount = 0;			
			my $q25th = 0;
			my $q75th = 0;
			foreach my $key (sort {$outcov{$a} <=> $outcov{$b}} keys %outcov){
				$sumcov += $outcov{$key};
				$medcount++;		
				if ($medcount == $bin25th){
					$q25th = $outcov{$key};
				}				
				if ($medcount == $halfbin){
					$median = $outcov{$key};					
				}
				if ($medcount == $bin75th){
					$q75th = $outcov{$key};
				}							
			}					
			my $avgcoverage = sprintf("%.2f",$sumcov/$bin);			
			print OUT "$contig\t$start\t$countpos$outstr\t$avgcoverage\t$median\t$q25th\t$q75th\n";
			$start = $countpos;
			%outcov = ();
		}
			
	}
}

close IN;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "minid|m:s", "maxid|x:s", "bin|b:s", "minreadlength|r:s", "binsize|d:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    exec("pod2usage $0") if (0 == (keys (%options) ));

    # If the -help option is set, print the usage and exit
    #
    exec("pod2usage $0") if $options{'help'};

    # Compulsosy items
    #if(!exists $options{'infile'} ) { print "**ERROR: $0 : \n"; exec("pod2usage $0"); }

    return \%options;
}

sub overrideDefault
{
    #-----
    # Set and override default values for parameters
    #
    my ($default_value, $option_name) = @_;
    if(exists $global_options->{$option_name}) 
    {
        return $global_options->{$option_name};
    }
    return $default_value;
}

__DATA__

=head1 NAME

    vprobes.generateprobes.pl

=head1 COPYRIGHT

   copyright (C) 2012 Mads Albertsen

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION



=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      In SAM file 
 [-outputfile -o]     Outputfile
 [-minid -m]          Minimum # mismatches (default: 0)
 [-maxid -x]          Maximum # mismatches (default: 38)
 [-bin -b]            Genome bin size in bp (default: 10000)
 [-minreadlength -r]  The minimum readlength to use (default: 50)
 [-binsize -d]        Mismatch binsize (default 5)
 
=cut