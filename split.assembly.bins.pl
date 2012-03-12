#!/usr/bin/env perl
###############################################################################
#
#    split.assembly.bins.pl
#
#	 Splits a fasta file into different fasta files based on a binning file
#    The binning need to be scaffoldname "tab" bin.
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
my $inbins;

$inputfile = &overrideDefault("inputfile.fasta",'inputfile');
$inbins = &overrideDefault("inbins.tab",'inbins');


my $header;
my $seq;
my $prevheader;
my $count = 0;
my %bins;
my %contigs;
my %sequences;

######################################################################
# CODE HERE
######################################################################


open(INbins, $inbins) or die("Cannot read file: $inputfile\n");
open(INfasta, $inputfile) or die("Cannot read file: $inputfile\n");
#my $outputfile;
#open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while (my $line = <INbins> ) {                                                                     #Read in the bins
	chomp $line; 
	my @splitline = split(/\t/, $line);
	$contigs{$splitline[0]} = $splitline[1];
	if (exists($bins{$splitline[1]})){
		$bins{$splitline[1]}++;
	}
	else{
		$bins{$splitline[1]} = 1;
	}
}
close INbins;

while (my $line = <INfasta>)  {	                                                                   #Read in the sequences
	chomp $line;
	if ($line =~ m/>/) {
		$header = $line;
		if ($count > 0){
			$sequences{$prevheader} = $seq;
		}
		$count++;
		$seq = "";
		$prevheader = $header;		
	}
	else{
		$seq = $seq.$line;
	}
}
$sequences{$prevheader} = $seq;                                                                    #To catch the last sequence..
close INfasta;

foreach my $bin (sort keys %bins) {
	my $outputfile = "bin.".$bin.".fasta";
	open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
	my $count1 = 0;
	my $length = 0;
	foreach my $contig (keys %contigs){
		if ($bin eq $contigs{$contig}){
			print OUT "$contig\n";
			print OUT "$sequences{$contig}\n";			
			$count1++;
			$length = $length + length($sequences{$contig});
		}		
	}
	print "bin:$bin\tsequences:$count1\tLength:$length\n";
	close OUT;
}



######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "inbins|b:s");
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

    split.assembly.bins.pl

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

script.pl  -i -b [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input fasta file. 
 [-inbins -b]         Tab seperated binfile (format: name tab bin)
 
=cut