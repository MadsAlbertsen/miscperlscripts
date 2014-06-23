#!/usr/bin/env perl
###############################################################################
#
#    silva_to_rdp.pl
#
#	 1) Download the newest release of the silva database in fasta format e.g. "SSURef_NR99_115_tax_silva_trunc.fasta".
#    2) Cluster the silva database at the desired level using usearch:
#       A) ./usearch7.0.1090 -sortbylength SSURef_NR99_115_tax_silva_trunc.fasta -output sorted.fa -minseqlength 1000 -notrunclabels
#       B) ./usearch7.0.1090 -cluster_smallmem sorted.fa -id 0.97 -centroids nr.fasta -notrunclabels
#    3) Supply the clustered file:
#       silva_to_rdp.pl -i nr.fasta     
#    4) Outputs:
#       A) tax.txt: A taxonomy file with 6 (genus) or 7 ranks (species). If the input sequence has less than 7 ranks a blank assignment is added (e.g. g__). If >7 ranks the first 7 are reported (the case for many eukaryotes).
#       B) ref.fasta: A fasta file with the sequences, but with only the identifier in the header.
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

my $infa;
my $outref;
my $start;
my $end;
my $minlength;

$infa = &overrideDefault("infa.fa",'infa');
$outref = &overrideDefault("ref.fasta",'outref');
$start = &overrideDefault(0,'start');
$end = &overrideDefault(50000,'end');
$minlength = &overrideDefault(425,'minlength');
 
my $seq = "";
my $count = 0;
my $header = "";

######################################################################
# CODE HERE
######################################################################

open(IN_fa, $infa) or die("Cannot read file: $infa\n");
open(OUT_ref, ">$outref") or die("Cannot create file: $outref\n");

while ( my $line = <IN_fa> ) {
	chomp $line;   
#	$line =~ s/\r\n//g;                                                                                      # Windows handle to unix file endings
#	$line =~ s/\r//g;                                                                                        # Windows handle to unix file endings
	$count++;
	if ($line =~ m/>/){
		if ($count > 1){
			$seq =~ s/ //g;
			my $seq_out = substr($seq, $start, $end-$start);
			$seq_out = uc($seq_out);
			$seq_out =~ s/U/T/g;
			$seq_out =~ s/\.//g;
			$seq_out =~ s/-//g;
			if (length($seq_out) >= $minlength) {
				print OUT_ref "$header\n";
				print OUT_ref "$seq_out\n";
			}
			$header = "";
		}		
		$header = $line;
		$seq = "";
	} else {
		$seq = $seq . $line;
	}
}

$seq =~ s/ //g;
my $seq_out = substr($seq, $start, $end-$start);
$seq_out = uc($seq_out);
$seq_out =~ s/U/T/g;
$seq_out =~ s/\.//g;
$seq_out =~ s/-//g;
if (length($seq_out) >= $minlength) {
	print OUT_ref "$header\n";
	print OUT_ref "$seq_out\n";
}
close IN_fa;
close OUT_ref;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "infa|i:s", "outref|r:s", "start|s:s", "end|e:s", "minlength|m:s");
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

    silva_to_rdp.pl

=head1 COPYRIGHT

   copyright (C) 2014 Mads Albertsen

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

silva_to_rdp.pl  -i [-h -t -r -g]

 [-help -h]      Displays this basic usage information
 [-infa -i]      Silva aligned sequences in fasta format.
 [-outref -r]    Output file.
 [-start -s]     Start of extraction, 27F:43 (default:0)
 [-end -e]       End of extraction, 534R:12000 (default: 50000)
 [-minlength -m] Minimum length of output sequences (default: 425)
 
=cut
