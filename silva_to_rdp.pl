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
my $outtax;
my $outref;
my $genus;
my $Eukaryota;

$infa = &overrideDefault("infa.fa",'infa');
$outtax = &overrideDefault("tax.txt",'outtax');
$outref = &overrideDefault("ref.fasta",'outref');
$genus = &overrideDefault(0,'genus'); 
$Eukaryota = &overrideDefault(0,'Eukaryota'); 
 
my %tax;
my $print = 0;
my $seq = "";
my $count = 0;
my $header = "";
my $euk = "";
my $taxstring = "";
my $dub = "";

######################################################################
# CODE HERE
######################################################################

open(IN_fa, $infa) or die("Cannot read file: $infa\n");
open(OUT_tax, ">$outtax") or die("Cannot create file: $outtax\n");
open(OUT_ref, ">$outref") or die("Cannot create file: $outref\n");

while ( my $line = <IN_fa> ) {
	chomp $line;   
	#$line =~ s/\r\n//g;                                                                                      # Windows handle to unix file endings
	#$line =~ s/\r//g;                                                                                        # Windows handle to unix file endings
	$count++;
	if ($line =~ m/>/){
		$line =~ s/>//;
		$line =~ s/\*//g;               
		my @split = split(/ /, $line, 2);
		my @splittax = split(/;/, $split[1]);
		my @splitid = split(/\./, $line, 2);
		my $id = "";
		if (!exists($tax{$splitid[0]})){ $tax{$splitid[0]} = 1 } else {	$tax{$splitid[0]}++;print "Error, discarding sequence! $splitid[0] seen $tax{$splitid[0]} times\n";	}                        # Check that the entry is not duplicated!
		if (exists($splittax[0])) {$id = $id . "k__" . $splittax[0]} else{$id = $id . "\tk__"}
		if (exists($splittax[1])) {$id = $id . ";p__" . $splittax[1]} else{$id = $id . ";p__"}
		if (exists($splittax[2])) {$id = $id . ";c__" . $splittax[2]} else{$id = $id . ";c__"}
		if (exists($splittax[3])) {$id = $id . ";o__" . $splittax[3]} else{$id = $id . ";o__"}
		if (exists($splittax[4])) {$id = $id . ";f__" . $splittax[4]} else{$id = $id . ";f__"}
		if (exists($splittax[5])) {$id = $id . ";g__" . $splittax[5]} else{$id = $id . ";g__"}
		if ($genus == 0){ if (exists($splittax[6])) {$id = $id . ";s__" . $splittax[6]} else{$id = $id . ";s__"}}
		if ($count > 1){			
			$seq = uc($seq);
			$seq =~ s/U/T/g; 
			if ($dub == 1){	$print = 1 }
			if ($euk =~ m/Eukaryota/ and $Eukaryota == 1) {	$print = 0 }
			if ($print == 1){
				print OUT_ref "$header\n";
				print OUT_ref "$seq\n";
				print OUT_tax "$taxstring\n";
			}
			$print = 0;
			$seq = "";
			$header = "";
			$taxstring = "";
			$euk = "";
			$dub = "";
		}
		$header = ">$splitid[0]";
		$taxstring = "$splitid[0]\t$id";
		$euk = $splittax[0];
		$dub = $tax{$splitid[0]};
	} else {
		$seq = $seq . $line;
	}
}

$seq = uc($seq);
$seq =~ s/U/T/g; 
if ($dub == 1){$print = 1}
if ($euk =~ m/Eukaryota/ and $Eukaryota == 1) {	$print = 0 }
if ($print == 1){
	print OUT_ref "$header\n";
	print OUT_ref "$seq\n";
	print OUT_tax "$taxstring\n";
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
    my @standard_options = ( "help|h+", "infa|i:s", "outtax|t:s", "outref|r:s", "genus|g:+", "Eukaryota|e:+");
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
 [-infa -i]      Usearch clustered fasta file of the original silva file
 [-outtax -t]    Output taxonomic file for the rdp classifier
 [-outref -r]    Output reference sequences for the rdp classifier
 [-genus -g]     Report genus level assignments instead of species (flag, default no)
 [-Eukaryota -e] Flag to indicate that Eukaryota should be removed.
 
=cut
