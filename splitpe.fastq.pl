#!/usr/bin/env perl
###############################################################################
#
#    splitpe.fastq.pl
#
#	 Splits a merged fastq file.
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

$inputfile = &overrideDefault("inputfile.txt",'inputfile');

my $line;
my $readcount;
my $printreadcount = 0;
my $linenr = 0;

######################################################################
# CODE HERE
######################################################################

open(IN, $inputfile1) or die("Cannot open $inputfile\n");
open(OUT, ">$p1.fastq") or die("Cannot create p1.fastq\n");
open(OUT2, ">$p2.fastq") or die("Cannot create p2.fastq\n");

print "Splitting reads into 2 files..\n";
while ( $line = <IN> ) {
	chomp $line;
	if ($printreadcount == 1000000) {
		$printreadcount = 0;
		print "$readcount PE reads split\n";
	}
	$linenr++;
	if ($linenr == 1){		
		print OUT "$line\n";		
		$readcount++;
		$printreadcount++;
	}
	if ($linenr == 2 ){		
		print OUT "$line\n";
	}
	if ($linenr == 3 ){		
		print OUT "$line\n";
	}	
	if ($linenr == 4){
		print OUT "$line\n";
	}
	if ($linenr == 5){		
		print OUT2 "$line\n";		
	}
	if ($linenr == 6 ){		
		print OUT2 "$line\n";
	}
	if ($linenr == 7 ){		
		print OUT2 "$line\n";
	}	
	if ($linenr == 8){
		print OUT2 "$line\n";
		$linenr =0;
	}	
}

print "done..\n";

close IN;
close OUT;
close OUT2;

exit;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s");
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
 [-inputfile -i]      Input merged pe fastq file.
 
=cut