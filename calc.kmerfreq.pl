#!/usr/bin/env perl
###############################################################################
#
#    calc.kmerfreq.pl
#
#	 Calculates kmer frequency in fasta files. 
#    Length restriction, variable kmer, and rc kmer to remove strand bias.
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

my $fastafile;;
my $outfile;
my $minlength;
my $kmerlength;

$fastafile = &overrideDefault("inputfile.fasta",'fastafile');
$outfile = &overrideDefault("outfile.tab",'outfile');
$minlength = &overrideDefault("10000",'minlength');
$kmerlength = &overrideDefault("4",'kmer');

my $line;
my $kmerlengthprobe;
my $header;
my $sequence;
my $count = -1;
my $printreadcount = 0;
my $seqcount = 0;
my $seqcountgood = 0;
my $totalkmers = 0;
my $output = "Contig";
my @probes;
my @kmerheader;
my %kmer;

######################################################################
# CODE HERE
######################################################################

open(IN, $fastafile) or die("Cannot open $fastafile\n");
open(OUT, ">$outfile") or die("Cannot create $outfile\n");

#Create all possible kmers

for (my $count2 = 0; $count2 < $kmerlength; $count2++)  {
	$kmerlengthprobe = $kmerlengthprobe."N";
}

push (@probes,$kmerlengthprobe);

foreach my $probe (@probes){
	if ($probe =~ m/N/) { 								# X or N = A, C or T
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
	if ($probe =~ m/N/) { 	
	}
	else{
		$output = $output."\t$probe";
		push (@kmerheader,$probe);
		$kmer{$probe} = 0;
	}
}
print OUT "$output\n";	

while ( $line = <IN> ) {
	chomp $line;
	$totalkmers = 0;
	$count++;	
	foreach my $probe1 (@kmerheader){                                                                                     #reset kmers
		$kmer{$probe1} = 0;		
	}
	if ($line =~ m/>/) { 	
		if ($minlength <= length($sequence) and $count > 0) {
			for (my $count2 = 0; $count2 < length($sequence); $count2++)  {
				if (exists($kmer{substr($sequence,$count2,$kmerlength)})){                                                    #to escape N's in scaffolds
					$kmer{substr($sequence,$count2,$kmerlength)}++;				
					my $rc = reverse(substr($sequence,$count2,$kmerlength));                                                  #Add reverse complement to escape string bias
					$rc =~ tr/ACGT/TGCA/;		
					$kmer{$rc}++;
					$totalkmers+= 2;
				}
			}
			if ($totalkmers > 0){
				foreach my $probe1 (@kmerheader){				
					my $temp1 = $kmer{$probe1}/$totalkmers;				
					$output = $output."\t$temp1";
				}
			print OUT "$output\n";
			$seqcountgood++;
			}
		}
		$sequence = "";	
		$header = $line;
		$output = $header;						
		$seqcount++;
		$printreadcount++;
		if ($printreadcount == 100) {
			$printreadcount = 0;
			print "$seqcount sequences $seqcountgood \>= $minlength bp\n";
		}
	}	
	else{		
		$sequence = $sequence.$line;
	}
}

####################stupid solution to get the last sequence...

$count++;
$totalkmers = 0;
if ($minlength <= length($sequence)) {
	foreach my $probe1 (@kmerheader){                                                                                    
		$kmer{$probe1} = 0;		
	}
	for (my $count2 = 0; $count2 < length($sequence); $count2++)  {
		if (exists($kmer{substr($sequence,$count2,$kmerlength)})){                                                    
			$kmer{substr($sequence,$count2,$kmerlength)}++;				
			my $rc = reverse(substr($sequence,$count2,$kmerlength));                                                 
			$rc =~ tr/ACGT/TGCA/;		
			$kmer{$rc}++;
			$totalkmers+= 2;
		}
	}
	$output = $header;
	foreach my $probe1 (@kmerheader){
		my $temp1 = $kmer{$probe1}/$totalkmers;
		$output = $output."\t$temp1";
	}
	print OUT "$output\n";	
}


close IN;
close OUT;

exit;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "fastafile|i:s", "outfile|i:s", "minlength|m:s", "kmer|k:s");
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

    calc.kmer.freq.pl

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

	Calculates kmer frequency in fasta files. 
	Length restriction, variable kmer, and rc kmer to remove strand bias.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-fastafile -i]      Input fastafile file. 
 [-outputfile -o]     Outputfile.
 [-minlength -m]      Minimum contig length (default: 10.000)
 [-kmer -k]           kmer (default: 4)
 
=cut