#!/usr/bin/env perl
###############################################################################
#
#    pb.to.mp.pl
#
#	 Converts PB data to convential MP data
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
my $outputfile;
my $minlength;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$minlength = &overrideDefault(2000,'minlength');

my $header = "";
my $seq = "";
my $count = 0;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	#$line =~ s/\r//g;
	if ($line =~ m/>/) {
		if ($seq ne "" and length($seq) >= $minlength) {
			$count++;
			my $f = substr($seq, 0, 100);
			my $r = substr($seq, length($seq)-100, length($seq));
			my $revcomp = reverse($r);
			$revcomp =~ tr/ACGTacgt/TGCAtgca/;
			 
			print OUT ">".$count."_1\n"; 
			print OUT "$f\n"; 
			print OUT ">".$count."_2\n"; 
			print OUT "$revcomp\n"; 
		}		
		$seq = "";	
	}
	else{
		$seq = $seq.$line;
	}
}

if (length($seq) >= $minlength) {
	$count++;
	my $f = substr($seq, 0, 100);
	my $r = substr($seq, length($seq)-100, length($seq));
	my $revcomp = reverse($r);
	$revcomp =~ tr/ACGTacgt/TGCAtgca/;
	 
	print OUT ">".$count."_1\n"; 
	print OUT "$f\n"; 
	print OUT ">".$count."_2\n"; 
	print OUT "$revcomp\n"; 
}

close IN;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "minlength|m:s");
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

    pb.to.mp.pl

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
 [-inputfile -i]      Inputfile 
 [-outputfile -o]     Outputfile
 [-minlength -m]           Minumum length
 
=cut