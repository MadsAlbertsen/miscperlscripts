#!/usr/bin/env perl
###############################################################################
#
#    extract.read2.using.read1.pl
#
#	 Used in digital normalization. First read1 library is digital normalized
#    by khmer scripts and then read2 is extracted using the remaining read1 reads
#    using this scripts. This ensures proper use of PE reads.    
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

my $inread1;
my $inread2;
my $outputfile;
my $splitheader;
my $print = 0;

$inread1 = &overrideDefault("read1.fa",'inread1');
$inread2 = &overrideDefault("read2.fa",'inread2');
$outputfile = &overrideDefault("read2.normalized.fa",'outputfile');
$splitheader = &overrideDefault("\#",'splitheader');
 
my $seq = ""; 
my $readfound = 0;
my %read1;

######################################################################
# CODE HERE
######################################################################

open(INread1, $inread1) or die("Cannot read file: $inread1\n");                                    #First read in all headers in the read 1 file that need to be matched in the read 2 file.

while ( my $line = <INread1> ) {
	chomp $line;   	
		if ($line =~ m/>/) {
		my @splitline = split(/$splitheader/,$line);
			$read1{$splitline[0]} = 1;
		}
}

close INread1;

open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
open(INread2, $inread2) or die("Cannot read file: $inread2\n");

while (my $line = <INread2>)  {	                                                                   #Look for matching read1 headers in the read2 file.
	chomp $line;
	if ($line =~ m/>/) {
		if ($readfound == 1){
			print OUT "$seq\n";
		}
		$readfound = 0;
		my @splitline = split(/$splitheader/,$line);
		if (exists($read1{$splitline[0]})){
			print OUT "$line\n";
			$readfound = 1;
		}
		$seq = "";
	}		
	else{
		$seq = $seq.$line;
	}
}
if ($readfound == 1){                                                                               #To catch the last sequence if needed
	print OUT "$seq\n";
}

close INread2;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inread1|i:s", "inread2|p:s","outputfile|o:s","splitheader|s:s");
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

extract.read2.using.read1.pl  -i -p [-h -o -s]

 [-help -h]           Displays this basic usage information
 [-inread1 -i]        Normalized Read1.fa.
 [-inread2 -p]        Unnormalized Read2.fa.
 [-outputfile -o]     Outputfile, (default: read2.normalized.fa). 
 [-splitheader -s]    Code used to split the header so read1 and 2 headers become identical (default: \#)
 
=cut