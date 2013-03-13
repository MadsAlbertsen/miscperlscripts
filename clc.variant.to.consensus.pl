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

my $variant;
my $reference;
my $outputfile;

$variant = &overrideDefault("variant.csv",'variant');
$reference = &overrideDefault("reference.fa",'reference');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my $header;
my $sequence = "";

######################################################################
# CODE HERE
######################################################################


open(IN_REF, $reference) or die("Cannot read file: $reference\n");
open(IN_VAR, $variant) or die("Cannot read file: $variant\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN_REF> ) {
	chomp $line;   	
	if ($line =~ m/>/) {
		$header = $line;
	}
	else{
		$sequence = "$sequence"."$line";
	}
}
close IN_REF;

my @seq = split(//,$sequence);

while ( my $line = <IN_VAR> ) {
	next if ($line =~ m/Reference Position/);                                   #To skip first line
	chomp $line;   	
	$line =~ s/"//g;
	my @splitline = split(",",$line);
	if ($splitline[3] eq "SNV"){
		$seq[$splitline[1]-1] = $splitline[14];
	}
	if ($splitline[3] eq "MNV"){
		for (my $count = $splitline[1]-1; $count <= $splitline[1]-1+$splitline[4]-1; $count++)  {
			$seq[$count] = "";
		}
		$seq[$splitline[1]-1] = $splitline[14];
	}
    if ($splitline[3] eq "InDel"){
		if ($splitline[4] == 0){
			$seq[$splitline[1]-2] = "$seq[$splitline[1]-2]$splitline[14]";
		}
		else{
			for (my $count = $splitline[1]-1; $count <= $splitline[1]-1+$splitline[4]-1; $count++)  {
				$seq[$count] = "";
			}
		}
	}
}

print OUT "$header.consensus\n";
print OUT join("",@seq)."\n";

close IN_VAR;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "variant|v:s", "reference|r:s", "outputfile|o:s");
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
 [-variant -v]        CLC cvs variant file 
 [-reference -r]      Reference fasta sequence
 [-outputfile -o]     Outputfile 
 
=cut