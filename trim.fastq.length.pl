#!/usr/bin/env perl
###############################################################################
#
#    trim.fastq.length.pl
#
#	 Removes short or long sequences
#    
#    Copyright (C) 2013 Mads Albertsen
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
my $maxlength;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$minlength = &overrideDefault(1,'minlength');
$maxlength = &overrideDefault(600,'maxlength');

my $line;
my $header;
my $sequence;
my $quality;
my $linenr = 0;
my $inseq = 0;
my $outseq = 0;

######################################################################
# CODE HERE
######################################################################

open(IN, $inputfile) or die("Cannot open $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create $outputfile\n");

while ( $line = <IN> ) {
	chomp $line;
	$linenr++;
	if ($linenr == 1){		
		$header = $line;		
	}
	if ($linenr == 2 ){		
		$sequence = $line;		
	}
	if ($linenr == 4){		
		$linenr = 0;
		$inseq++;
		if ((length($line) >= $minlength) and (length($line) <= $maxlength)){
			print OUT "$header\n";
			print OUT "$sequence\n";
			print OUT "+\n";
			print OUT "$line\n";
			$outseq++;
		}
	}	
}

print "$inseq sequences evaluated\n";
print "$outseq sequences within $minlength bp to $maxlength bp saved\n";

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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "minlength|m:s", "maxlength|x:s");
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

    splitpe.fastq.pl

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

	Splits a merged fastq file.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input fastq file
 [-outputfile -o]     Output fastq file
 [-minlength -m]      Minimum sequence length
 [-minlength -x]      Maximum sequence length
 
=cut
