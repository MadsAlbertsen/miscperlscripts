#!/usr/bin/env perl
###############################################################################
#
#    miseq.bad.multiplex.pl
#
#	 Demultiplexes bad miseq data
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
my $samplesheet;
my $minlength;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$samplesheet = &overrideDefault("samplesheet.csv",'samplesheet');

my $count = 0;

my %index;
my %samples;
my %hits;

######################################################################
# CODE HERE
######################################################################

open(IN_s, $samplesheet) or die("Cannot read file: $samplesheet\n");                               # First read in the samples sheet, extract the seqID and the barcodes
while ( my $line = <IN_s> ) {
	chomp $line;
	my @info = split(/,/, $line);
	my $length = scalar @info;
	if ($length >= 8 and  $info[0] ne "Sample_ID"){
		my $id = $info[4].$info[5];
		$samples{$id} = $info[1];                                                                      # Store the concatenated barcodes in the %samples hash
		$hits{$info[1]} = 0;                                                                           # Make a hash to store the counts of each sample
	}
}

close IN_s;

my $nmatch = 0;
my $smatch = 0;
my $mmatch = 0;
my $header = "";
my $seq = "";
my $qual = "";

open(IN, $inputfile) or die("Cannot read file: $inputfile\n");

while ( my $line = <IN> ) {                                                                        # Gather up the 4 lines of each entry
	chomp $line;   	
	$count++;
	if ($count == 1) {
		$header = $line;
	}
	if ($count == 2) {
		$seq = $line;
	}
	if ($count == 4) {                                             
		$qual = $line;
		my $match = 0;
		my $matchout = "";
		my $i = substr($seq, 301, 16);                                                             # Extract the barcode
		if (exists($index{$i})){
			$index{$i}++;
		} else {
			$index{$i} = 1;
		}
		$i =~ s/N/./g;                                                                             # Replace N with wildcard
		foreach my $key (keys %samples){                                            
			if ($key =~ m/$i/){                                                                    # Check if any of the original barcodes matches
				$match++;
				$matchout = $key;
			}
		}
		if ($match == 0){$nmatch++;}                                                               # If no match - just increase the no match counter
		if ($match >= 2){$mmatch++;}                                                               # If > 1 match - just increase the multi match counter
		if ($match == 1){                                                                          # If a single match then write the sequences to the appropiate files
			$smatch++;
			$hits{$samples{$matchout}}++;
			
			my $r1 = $samples{$matchout}."_R1.fastq";
			open(R1, ">>$r1") or die("Cannot create file: $r1\n");
			my $read1seq = substr($seq, 0, 301);
			my $read1qual = substr($qual, 0, 301); 
			print R1 $header."_1\n";
			print R1 $read1seq."\n";
			print R1 "+\n";
			print R1 $read1qual."\n";
			close R1;
			
			my $r2 = $samples{$matchout}."_R2.fastq";
			open(R2, ">>$r2") or die("Cannot create file: $r2\n");
			my $read2seq = substr($seq, 317, 301);
			my $read2qual = substr($qual, 317, 301); 
			print R2 $header."_1\n";
			print R2 $read2seq."\n";
			print R2 "+\n";
			print R2 $read2qual."\n";
			close R2;
		}
	$count = 0;
	}
}

close IN;

print "No match:\t$nmatch\n";
print "Single match:\t$smatch\n";
print "Multiple match:\t$mmatch\n";

open(OUT, ">stats.sample.txt") or die("Cannot create file: stats.sample.txt\n");
print OUT "SeqID\tHits\n";
foreach my $key (sort { $hits{$a} <=> $hits{$b} } keys %hits){                                     # Print sample specific hits
	print OUT "$key\t$hits{$key}\n";
}
close OUT;

open(OUT_i, ">stats.barcode.txt") or die("Cannot create file: stats.barcode.txt\n");
print OUT_i "Barcode1\tBarcode2\tHits\n";
foreach my $key (sort { $index{$a} <=> $index{$b} } keys %index){                                     # Print sample specific hits
	my $f = substr($key, 0, 8);
	my $r = substr($key, 8, 8);
	print OUT_i "$f\t$r\t$index{$key}\n";
}
close OUT_i;




######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "samplesheet|s:s");
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

    miseq.bad.multiplex.pl

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

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Complete fastq file.
 ]-samplesheet -s}    Samplesheet.
 
=cut