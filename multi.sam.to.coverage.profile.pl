#!/usr/bin/env perl
###############################################################################
#
#    multi.sam.to.count.profile.pl
#
#	 Short description
#    
#    Copyright (C) 2014 Mads Albertsen
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

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

my %length;
my %coverage;
my %samples;
my $description;
 

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while (my $line = <IN> ) {
	chomp $line;                                                       												     
	my @splitline = split(/\t/, $line); 	
	if ($line =~ m/\@SQ/) {                               												                  #if we are in the contig header area then retrive all contigs/scaffolds and store the name and length in the hash: contig		
			my @contigname = split(/:/, $splitline[1]);                     											  #Retrive the contig name
			my @contiglength = split(/:/, $splitline[2]);																  #Retrive the contig length
			$length{$contigname[1]} = $contiglength[1];                   												  #Make a hash with key = "contig name" and value = "contig length"			
		}	
	else {
		if ($line !~ m/(\@PG|\@HD|\@SQ|\@RG)/) { 
			my @samplename = split(/:/, $splitline[0]); 
			my $sample = "$samplename[0]:$samplename[1]:$samplename[2]:$samplename[3]:$samplename[9]";
			$samples{$sample} = 1;
			my $contig = $splitline[2];
			if (exists($coverage{$contig}{$sample})){
				$coverage{$contig}{$sample}++;
			}
			else{
				$coverage{$contig}{$sample} = 1;
			}
		}
	}
}

$description = "Contig";
foreach my $sample (keys %samples){
	$description = "$description\t$sample"
}
print OUT "$description\n";

foreach my $contig (keys %length){
	my $count = "$contig";
	foreach my $sample (keys %samples){
		if (exists($coverage{$contig}{$sample})){
			$count = "$count\t$coverage{$contig}{$sample}";
		}
		else{
			$count = "$count\t0";
		}
	}
	print OUT "$count\n";
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s");
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
 [-inputfile -i]      SAM file with mappings from multiple datasets. 
 [-outputfile -o]     Count file split on genes and dataset.
 
=cut