#!/usr/bin/env perl
###############################################################################
#
#    splitpe.fasta.pl
#
#	 Splits a merged paired end fastafile.
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

$inputfile = &overrideDefault("inputfile.fa",'inputfile');
 
my $line;
my $header;
my $prevheader;
my $seq;
my $count = 0;

######################################################################
# CODE HERE
######################################################################
	
open(IN, $inputfile) or die;
open(OUTp1, ">p1.fa") or die;
open(OUTp2, ">p2.fa") or die;

while (my $line = <IN>)  {	
	chomp $line;
	if ($line =~ m/>/) {
		$header = $line;
		if ($count == 1){
			print OUTp1 "$prevheader\n";
			print OUTp1 "$seq\n";			
		}
		if ($count == 2){
			print OUTp2 "$prevheader\n";
			print OUTp2 "$seq\n";			
			$count = 0;
		}
		$count++;
		$seq = "";
		$prevheader = $header;		
	}
	else{
		$seq = $seq.$line;
	}
}

print OUTp2 "$prevheader\n";
print OUTp2 "$seq\n";			

close IN;
close OUTp1;
close OUTp2;

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

    splitpe.fasta.pl

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

	Splits a merged paired end fastafile.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input merged paried end fasta file.
 
=cut