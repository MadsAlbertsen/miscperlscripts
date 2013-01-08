#!/usr/bin/env perl
###############################################################################
#
#    cytoscape.otu.cor.matrix.pl
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
my $outputfile;
my $lowcor;
my $highcor;
my $printnocorr;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$lowcor = &overrideDefault(0,'lowcor');
$highcor = &overrideDefault(0,'highcor');
$printnocorr = &overrideDefault(0,'printnocorr');
 
my @otus;
my %cor;  
my %printedcor;
my $linenr = 0;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	$linenr++;
	$line =~ s/"//g;                                                                              #Remove the "" as are exported by R by default 
	if ($linenr == 1){                                                                            #If it is the first line then extract all otu names
		@otus = split(" ", $line);
	}
	else{
		my @tempcor = split(" ", $line);
		my $count = 0;
		foreach my $key (@otus){			
			$count++;
			my $revid = "$key\t0\t$tempcor[0]";
			if (($tempcor[0] ne $key) and !exists($cor{$revid})){                            #Add min max criteria when this works on simple datasets.
				my $id = "$tempcor[0]\t0\t$key"; 
				$cor{$id} = $tempcor[$count];
			}
		}
	}
}

print OUT "node1\tinteraction\tnode2\tcorrelation\tabs.correlation\n";
foreach my $key (keys %cor){
	if ($cor{$key} < 0){
		if ($cor{$key} < -$lowcor){
			my $abscor = abs($cor{$key});
			print OUT "$key\t$cor{$key}\t$abscor\n";
			my @temp = split("\t",$key);
			$printedcor{$temp[0]} = 1;
			$printedcor{$temp[2]} = 1;
		}
	}
	else{
		if ($cor{$key} > $highcor){
			my $abscor = abs($cor{$key});
			print OUT "$key\t$cor{$key}\t$abscor\n";
			my @temp = split("\t",$key);
			$printedcor{$temp[0]} = 1;
			$printedcor{$temp[2]} = 1;
		}
	}
}

if ($printnocorr == 0){
	foreach my $key (@otus){
		if (!exists($printedcor{$key})){
			print OUT "$key\n";
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "lowcor|l:s", "highcor|h:s","printnocorr|p:+");
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

cytoscape.otu.cor.matrix.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Inputfile 
 [-outputfile -o]     Outputfile
 [-lowcor -l]         Negative correlation cutoff (0:1, default: 0) 
 [-highcor -h]        Positive correaltion cutoff (0:1, default: 0)
 [-printnocor -p]     Flag to disable printing of nodes with no cor
 
 
=cut