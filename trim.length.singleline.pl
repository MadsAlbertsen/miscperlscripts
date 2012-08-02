#!/usr/bin/env perl
###############################################################################
#
#    splitpe.fasta.pl
#
#	 Splits a combined paired end fastafile.
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
my $minlength;
my $stopcount;

$inputfile = &overrideDefault("inputfile.fa",'inputfile');
$outputfile = &overrideDefault("out.fa",'outputfile');
$minlength = &overrideDefault("100",'minlength');
$stopcount = &overrideDefault("1000000000000000",'stopcount');
 
my $line;
my $header = "error";
my $prevheader = "error";
my $seq;
my $count = 0;
my $seqsout = 0;

######################################################################
# CODE HERE
######################################################################
	
open(IN, $inputfile) or die("Cannot open $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create $outputfile");

while ( my $line = <IN> ) {
	chomp $line; 
	last if ($seqsout == $stopcount);
	if ($line =~ m/>/) {
		$prevheader = $header;
		$header = $line;
		if($count > 0){
			if (length($seq) > $minlength-1){
				print OUT "$prevheader\n";
				print OUT "$seq\n";
				$seqsout++;
			}
		}
		$seq = "";
		$count++;
	}
	else{
		$seq = $seq.$line;
	}
}

if ((length($seq)>$minlength-1) and ($seqsout != $stopcount)){
	print OUT "$header\n";
	print OUT "$seq\n";
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "minlength|m:s", "stopcount|s:s");
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

    trim.length.singleline.pl

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

	Splits a combined paired end fastafile.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input compined paried end fasta file.
 [-outputfile -o]     Optional outputfile (default: out.fa).
 [-minlength -m]      Minimum length of reads (default: 100).
 [-stopcount -s]      Max number of sequences to output.
 
=cut