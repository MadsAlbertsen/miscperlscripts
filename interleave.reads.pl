#!/usr/bin/env perl
###############################################################################
#
#    scriptname
#
#	 Short description
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

my $inputfile1;
my $inputfile2;
my $outputfile;

$inputfile1 = &overrideDefault("inputfile1.txt",'inputfile1');
$inputfile2 = &overrideDefault("inputfile2.txt",'inputfile2');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my @forward;
my @reverse;
my $count = 0;
 
######################################################################
# CODE HERE
######################################################################


open(IN1, $inputfile1) or die("Cannot read file: $inputfile1\n");
open(IN2, $inputfile2) or die("Cannot read file: $inputfile2\n");

open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( defined(my $line1 = <IN1>) and  defined(my $line2 = <IN2>) ) {
	$count++;
	chomp($line1);	
	chomp($line2); 	
	push (@forward, $line1);
	push (@reverse, $line2); 	
	if ($count == 4){
		print OUT join("\n",@forward),"\n";
		print OUT join("\n",@reverse),"\n";
		$count = 0;
		@forward = ();
		@reverse = ();		
	}
}

close IN1;
close IN2;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile1|f:s","inputfile2|r:s", "outputfile|o:s");
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

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inpufile1 -f]      Forward read. 
 [-inpufile2 -r]      Reverse read. 
 [-outputfile -o]     Outputfile. 
 
=cut