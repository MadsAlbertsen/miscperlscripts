#!/usr/bin/env perl
###############################################################################
#
#    extract.pe.reads.using.single.pl
#
#	 Given a list of single reads it extracts the PE reads from 2 PE fastq files.   
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


my $insingle;
my $inread1;
my $inread2;
my $splitheader;
my $splitfasta;
my $print = 0;
my $linecount = 0;

$inread1 = &overrideDefault("read1.fastq",'inread1');
$inread2 = &overrideDefault("read2.fastq",'inread2');
$insingle = &overrideDefault("single.fa",'insingle');
$splitheader = &overrideDefault(" ",'splitheader');
$splitfasta = &overrideDefault("_",'splitfasta');
 
my $seq = ""; 
my $readfound = 0;
my $toextract = 0;
my $extracted = 0;
my %reads;

######################################################################
# CODE HERE
######################################################################

open(INsingle, $insingle) or die("Cannot read file: $insingle\n");                                    #First read in all headers in the read 1 file that need to be matched in the read 2 file.

while ( my $line = <INsingle> ) {
	chomp $line;   	
	if ($line =~ m/>/) {
		$line =~ s/>//; 	
		my @splitline = split(/$splitfasta/,$line);		
		$reads{$splitline[0]} = 1;
		$toextract++;
	}
}
print "Found $toextract single reads.\n";
close INsingle;

open(OUT1, ">$inread1.sub.fastq") or die("Cannot create file: $inread1.sub.fastq\n");
open(INread1, $inread1) or die("Cannot read file: $inread1\n");

while (my $line = <INread1>)  {	                                                                   #Look for matching read1 headers in the read2 file.
	chomp $line;
	$linecount++;
	if ($linecount == 1){
		my @splitline = split(/\@/,$line); 
		my @splitline1 = split(/$splitheader/,$splitline[1]);
		if (exists($reads{$splitline1[0]})){
			$print = 1;
			$extracted++;
		}
	}			
	if ($print == 1){
		print OUT1 "$line\n";
	}
	if ($linecount == 4){
		$linecount = 0;
		$print = 0;
	}
}
print "Extracted $extracted reads from read 1.\n";
close INread1;
close OUT1;

open(OUT2, ">$inread2.sub.fastq") or die("Cannot create file: $inread2.sub.fastq\n");
open(INread2, $inread2) or die("Cannot read file: $inread2\n");
$extracted = 0;
while (my $line = <INread2>)  {	                                                                   #Look for matching read1 headers in the read2 file.
	chomp $line;
	$linecount++;
	if ($linecount == 1){
		my @splitline = split(/\@/,$line); 
		my @splitline1 = split(/$splitheader/,$splitline[1]);
		if (exists($reads{$splitline1[0]})){
			$print = 1;
			$extracted++;
		}
	}			
	if ($print == 1){
		print OUT2 "$line\n";
	}
	if ($linecount == 4){
		$linecount = 0;
		$print = 0;
	}
}
print "Extracted $extracted reads from read 2.\n";
close INread2;
close OUT2;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inread1|f:s", "inread2|r:s","splitheader|x:s","insingle|s:s","splitfasta|y:s");
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

    extract.read2.using.read1.pl

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

Used in digital normalization. First read1 library is digital normalized
by khmer scripts and then read2 is extracted using the remaining read1 reads
using this scripts. This ensures proper use of PE reads. 


=head1 SYNOPSIS

extract.read2.using.read1.pl  -f -r -s [-h -x]

 [-help -h]           Displays this basic usage information
 [-inread1 -f]        Read1.fastq.
 [-inread2 -r]        Read2.fastq. 
 [-insingle -s]       Singlereads.fa. 
 [-splitheader -x]    Code used to split the header of the fastq files (default: "_")
 [-splitfasta -y]     Code used to split the header of the fasta file (default: " ")
 
=cut