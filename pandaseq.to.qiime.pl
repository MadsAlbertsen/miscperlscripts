#!/usr/bin/env perl
###############################################################################
#
#    pandaseq.to.qiime.pl
#
#    Reformats a merged fasta file from pandaseq into qiime ready format
#    including a map file. You need to supply a sample id file.
#    The sampleid file must contain a sequence header from each sample
#    separated by tab and a proper sampleid, e.g.:
#    >HWI-ST1040:49:D0HVDACXX:1:1101:4215:2592:AAGGCTAC "tab" n.1a2.p
#
#    #    Copyright (C) 2012 Mads Albertsen
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

my $dir;
my $sampleidfile;
my $subsample;
my $infile;

$dir = &overrideDefault(".",'dir');
$sampleidfile = &overrideDefault("0",'sampleidfile');
$subsample = &overrideDefault("0",'subsample');
$infile = &overrideDefault("merged.reads.fasta",'infile');

my $filename;
my $sampleid = 0;
my $barcodecounter = 0;
my @headerid;
my @probes;
my %barcode;
my %sdisc;
my %sid;
my %seqlength;
my %histogram;
my $minlength = 10000;
my $maxlength = 0;


######################################################################
# CODE HERE
######################################################################

open(OUTmap, ">map.txt") or die("Cannot create file: map.txt\n");
open(OUTseq, ">seqs.fna") or die("Cannot create file: seqs.txt\n");
open(OUThist, ">histograms.txt") or die("Cannot create file: histograms.txt\n");
open(OUTbad, ">no.known.header.txt") or die("Cannot create file: no.known.header.txt\n");
open(INreads, "$infile") or die("Cannot open: $infile\n");
print OUTmap "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tTreatment\tDOB\tDescription\n";

push (@probes,"NNNNNAAAA");                                                                         #Generating 4^5 new barcodes (1024...) should be enoungh..
foreach my $probe (@probes){
	if ($probe =~ m/N/) { 								
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
	if ($probe !~ m/N/) { 
		$barcodecounter++;
		$barcode{$barcodecounter} = $probe;
	}
}

open(INsid, "$sampleidfile") or die("Cannot open file $sampleidfile\n");	                       #Load the sample info file
while ( my $line = <INsid> ) {
	chomp $line;
	my @splitline = split(/\t/,$line);
	$sampleid++;
	my @splitline1 = split(/:/,$splitline[0]);
	my $tempheader = $splitline1[0].".".$splitline1[1].".".$splitline1[2].".".$splitline1[3].".".$splitline1[7];
	$sdisc{$tempheader} = $splitline[1];	
	$sid{$tempheader} = $barcode{$sampleid};	
	print OUTmap "$splitline[1]\t$barcode{$sampleid}\tYATGCTGCCTCCCGTAGGAGT\tNA\tNA\t$tempheader\n";		
}
close INsid;


my $linenr = 0;
my $headernr = 0;
my $seqnr = 0;
my %scount;
$sampleid++;		
while (my $line = <INreads>)  {	                                                                   
	chomp $line;
	if ($headernr == 0) {
		@headerid = split(/:/,$line);
		$headernr = 1;					
	}
	else{
		$headernr = 0;	
		my $tempheader = $headerid[0].".".$headerid[1].".".$headerid[2].".".$headerid[3].".".$headerid[7]; 
		if (exists($scount{$tempheader})){
			$scount{$tempheader}++;
			if ($subsample > 0 and $scount{$tempheader} > $subsample){                             #To be able to subsample the file by only writing x sequences.
				next;				
			}
		}
		else{
			$scount{$tempheader} = 1;
		}				
		if (exists($sdisc{$tempheader})){			
			print OUTseq "$sdisc{$tempheader}_$scount{$tempheader} orig_bc=$headerid[7] new_bc=$sid{$tempheader} bc_diffs=0\n";
			print OUTseq "$line\n";
			my $templength = length($line);
			if ($templength > $maxlength){
				$maxlength = $templength;
			}
			if ($templength < $minlength){
				$minlength = $templength;
			}
			my $tempid = $sdisc{$tempheader}.";".$templength;
			if (exists $seqlength{$tempid}){
				$seqlength{$tempid}++;
			}
			else{
				$seqlength{$tempid} = 1;
			}
		}
		else{
			my $tempheader = $headerid[0].".".$headerid[1].".".$headerid[2].".".$headerid[3].".".$headerid[7];
			print OUTbad "$tempheader";
			print OUTbad "$line\n";
		}
	}
}

for (my $count = $minlength; $count <= $maxlength; $count++){                                      #Make a histogram of the readlength
	$histogram{$count} = $count;
	foreach my $tempid (sort keys %sdisc){
		my $tid = $sdisc{$tempid}.";".$count;
		if (exists($seqlength{$tid})){
			$histogram{$count} = "$histogram{$count}\t$seqlength{$tid}";			
		}
		else{
			$histogram{$count} = "$histogram{$count}\t0";
		}
	}
}

my $lenh = "Length";
foreach my $tempid2 (sort keys %sdisc){
	$lenh = "$lenh\t$sdisc{$tempid2}";
}
print OUThist "$lenh\n";

foreach my $tkeys (sort{$a<=>$b} keys %histogram){                                                 #Numerical sort added
	print OUThist "$histogram{$tkeys}\n";
}

foreach my $tkeys (keys %scount){                                                 #Numerical sort added
	print "$tkeys $scount{$tkeys}\n";
}



close OUTmap;
close OUTseq;
close OUThist;
close OUTbad;
close INreads;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "infile|i:s","sampleidfile|s:s","subsample|m:s");
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

    pandaseq.to.qiime.pl

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

Write a few words..

script.pl  -i -s [-h -m]

 [-help -h]           Displays this basic usage information.
 [-infile -i]         Single merged pandaseq output file in fasta format. 
 [-sampleidfile -s]   File containing sample id for each file must be as filename "tab" sampleid.
 [-subsample -m]      Only use the first X reads (default: off).
 
=cut