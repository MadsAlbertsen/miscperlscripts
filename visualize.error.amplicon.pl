#!/usr/bin/env perl
###############################################################################
#
#    visualize.error.amplicon.pl
#
#	 Takes an input fastafile and calculates the number of 1 
#    nucleotide mismatches to the X most abundant sequences.
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

my $inseqs;
my $outputfile;
my $printmax;

$inseqs = &overrideDefault("inseqs.txt",'inseqs');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$printmax = &overrideDefault(10,'printmax');


my $orgseq;
my %seqs;
my $printcount = 0;
my @selectedotus;
 

######################################################################
# CODE HERE
######################################################################


open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

open(INseqs, $inseqs) or die("Cannot read file: $inseqs\n");
while ( my $line = <INseqs> ) {
	chomp $line;   
	if ($line !~ m/>/) { 	
		if (!exists $seqs{$line}){
			$seqs{$line} = 1;
		}
		else{		
			$seqs{$line}++;
		}
	}
}
close INseqs;

foreach my $key (sort { $seqs{$b} <=> $seqs{$a} } keys %seqs){
	$printcount++;
	if ($printcount<=$printmax){
		push (@selectedotus, $key)
	}
}

print OUT "Position\tNucl.Sub\tCount\tParent.OTU\n";

foreach my $line (@selectedotus)  {  
	my %otus;
	my %otucount;   		
	my $parentotu = $line;
	$otus{$line} = "0\t0";
	$otucount{$otus{$line}} = 0;
	my @nucl =  split(//, $line); 
	for (my $count = 1; $count < length($line); $count++) {
		if ("A" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "A";
			my $newotu = join("",@temp);
			$otus{$newotu} = "$count\tA";	
			$otucount{$otus{$newotu}} = 0;
		}
		if ("T" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "T";
			my $newotu = join("",@temp);
			$otus{$newotu} = "$count\tT";	
			$otucount{$otus{$newotu}} = 0;
		}
		if ("C" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "C";
			my $newotu = join("",@temp);
			$otus{$newotu} = "$count\tC";	
			$otucount{$otus{$newotu}} = 0;
		}
		if ("G" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "G";
			my $newotu = join("",@temp);
			$otus{$newotu} = "$count\tG";	
			$otucount{$otus{$newotu}} = 0;
		}
	}
	open(INseqs, $inseqs) or die("Cannot read file: $inseqs\n");
	while ( my $line = <INseqs> ) {
		chomp $line;   
		if ($line !~ m/>/) { 	
			if (exists $otus{$line}){
				$otucount{$otus{$line}}++;	
			}
		}
	}
	close INseqs;
	foreach my $key (sort keys %otucount){
		print OUT "$key\t$otucount{$key}\t$parentotu\n";
	}
}







close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inseqs|i:s", "outputfile|o:s", "printmax|m:s");
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

visualize.error.amplicon.pl  -i [-o -p -h]

 [-help -h]           Displays this basic usage information
 [-inseqs -i]         Sequence file with all sequences.
 [-outputfile -o]     Outputfile. 
 [-printmax -m]       The number of abundant otus to use.
 
=cut