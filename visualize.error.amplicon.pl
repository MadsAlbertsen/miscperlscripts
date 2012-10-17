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
my $outstats;
my $printmax;

$inseqs = &overrideDefault("inseqs.txt",'inseqs');
$outstats = &overrideDefault("outstats.txt",'outstats');
$printmax = &overrideDefault(10,'printmax');


my $orgseq;
my %seqs;
my %stats;
my $printcount = 0;
my @selectedotus;
my $percent;
my $seqcount = 0;
 

######################################################################
# CODE HERE
######################################################################


open(OUT, ">$outstats") or die("Cannot create file: $outstats\n");

open(INseqs, $inseqs) or die("Cannot read file: $inseqs\n");                                       #Add the sequences to a hash table
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

foreach my $key (sort { $seqs{$b} <=> $seqs{$a} } keys %seqs){                                     #Sort the sequences by abundance and select the X most abundant seqs
	$printcount++;
	if ($printcount<=$printmax){
		push (@selectedotus, $key)
	}
}

foreach my $line (@selectedotus)  {                                                                #Find the abundance of all associated OTUs
	my $parentotu = $line;
	$stats{$parentotu} = 100;
	my @nucl =  split(//, $line); 
	for (my $count = 0; $count < length($line); $count++) {
		if ("A" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "A";
			my $newotu = join("",@temp);
			if (exists($seqs{$newotu})){
				$percent = $seqs{$newotu}/$seqs{$parentotu}*100;				
			}
			else{
				$percent = 0;
			}		
			
			$stats{$parentotu} = "$stats{$parentotu}\t$percent";
		}
		if ("T" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "T";
			my $newotu = join("",@temp);
			if (exists($seqs{$newotu})){
				$percent = $seqs{$newotu}/$seqs{$parentotu}*100;	
			}
			else{
				$percent = 0;
			}	
			$stats{$parentotu} = "$stats{$parentotu}\t$percent";			
		}
		if ("C" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "C";
			my $newotu = join("",@temp);
			if (exists($seqs{$newotu})){
				$percent = $seqs{$newotu}/$seqs{$parentotu}*100;	
			}
			else{
				$percent = 0;
			}		
			$stats{$parentotu} = "$stats{$parentotu}\t$percent";	
		}
		if ("G" ne $nucl[$count]){
			my @temp = @nucl;
			$temp[$count] = "G";
			my $newotu = join("",@temp);
			if (exists($seqs{$newotu})){
				$percent = $seqs{$newotu}/$seqs{$parentotu}*100;	
			}
			else{
				$percent = 0;
			}
			$stats{$parentotu} = "$stats{$parentotu}\t$percent";			
		}
	}
	$seqcount++;
	print OUT "$seqcount\_$seqs{$parentotu}\t$stats{$parentotu}\n";
	delete($seqs{$parentotu});	
}

close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inseqs|i:s", "outstats|s:s", "printmax|m:s");
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
 [-inseqs -i]         Sequence file with all sequences
 [-outstats -s]       Statsfile
 [-printmax -m]       The number of abundant otus to use
 
=cut