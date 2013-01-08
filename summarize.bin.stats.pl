#!/usr/bin/env perl
###############################################################################
#
#    scriptname
#
#	 Short description
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
my $essfile;
my $ess31file;
my $outputfile;
my $length;
my $hmm;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$essfile = &overrideDefault("essfile.txt",'essfile');
$ess31file = &overrideDefault("ess31file.txt",'ess31file');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$length = &overrideDefault(3,'length');
$hmm = &overrideDefault(8,'hmm');

my $linecount = 0;
my $sumlength = 0;
my %outcontigs;
my %sumhmm;
 

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(ESS, $essfile) or die("Cannot read file: $essfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	if ($linecount!=0){
		my @splitline = split(/"/,$line);
		$outcontigs{$splitline[1]} = 1;
		my @splitline2 = split(/ /,$splitline[2]);
		$sumlength+= $splitline2[$length];
	}
	$linecount++;
}
print OUT "#Contings\t$linecount\n";
print OUT "Total Length\t$sumlength\n";

$linecount = 0;


while ( my $line = <ESS> ) {
	chomp $line;  
	if ($linecount!=0){ 	
		my @splitline = split(/\t/,$line);
		if (exists($outcontigs{$splitline[0]})){
			if (exists($sumhmm{$splitline[$hmm]})){
				$sumhmm{$splitline[$hmm]}++;
			}
			else{
				$sumhmm{$splitline[$hmm]} = 1;
			}
		}	
	}
	$linecount++;
}

$linecount = 0;
my $summedhmms = 0;

foreach my $key (keys %sumhmm){
	$linecount++;
	$summedhmms += $sumhmm{$key};
}

print OUT "Total Unique Hmms\t$linecount\n";
print OUT "Total Hmms\t$summedhmms\n";


foreach my $key (sort {$sumhmm{$b} <=> $sumhmm{$a}} keys %sumhmm){
	print OUT "$key\t$sumhmm{$key}\n";
}

close ESS;
close IN;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s","essfile|e:s","ess31file|b:s","length|l:s","hmm|h:s");
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
 [-inputfile -i]      Inputfile 
 [-outputfile -o]     Outputfile
 [-essfile -e]        Essential gene file 
 [-ess31file -b]      File with the 31 ess genes
 [-length -l ]        Column with lenght stats
 [-hmm -h]            Column with hmm identifier
 
=cut