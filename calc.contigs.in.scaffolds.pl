#!/usr/bin/env perl
###############################################################################
#
#    calc.contigs.in.scaffolds.pl
#
#	 Calculates the number of contigs in a given scaffold and the number of N's
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

$inputfile = &overrideDefault("inputfile.fasta",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my $line;
my $seq2;
my $dummy = 0;
my $header;

######################################################################
# CODE HERE
######################################################################

	
open(IN, $inputfile) or die;
open(OUT, ">$outputfile") or die;


while (my $line = <IN>)  {
	if ($line =~ m/>/) {
		chomp $line;
		if ($dummy == 1){
			my @seq = split("", $seq2);
			my $Ncount = 0;
			my $Ccount = 1;
			my $prevnucl = "";
			foreach my $nucl (@seq) {
				if 	($nucl eq "N"){
					$Ncount++;
					if ($nucl ne $prevnucl){
						$Ccount++;
					}
				}	
				$prevnucl = $nucl;
			}
			print OUT "$header\t$Ccount\t$Ncount\n";
		}
		$header = "$line";
		$dummy =1;
		$seq2 = "";
	}
	else {
		chomp $line;
		$seq2 = $seq2.$line;
		}
}
my @seq = split("", $seq2);
my $Ncount = 0;
my $Ccount = 1;
my $prevnucl = "";
foreach my $nucl (@seq) {
	if 	($nucl eq "N"){
		$Ncount++;
		if ($nucl ne $prevnucl){
			$Ccount++;
		}
	}	
	$prevnucl = $nucl;
}
print OUT "$header\t$Ccount\t$Ncount\n";

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

    calc.gc.pl

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

script.pl  -i [-h -o]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input fasta file. 
 [-outputfile -o]     Outputfile.
 
=cut