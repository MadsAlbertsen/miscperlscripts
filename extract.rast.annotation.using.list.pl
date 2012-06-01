#!/usr/bin/env perl
###############################################################################
#
#    extract.rast.annotation.using.list.pl
#
#	 Given a list of nodes extracts all parts of the relating graph in a 
#    cytoscape connection file (nodes in column 0 and 2).
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

my $inrast;
my $inlist;

$inrast = &overrideDefault("inrast.txt",'inrast');
$inlist = &overrideDefault("inlist.txt",'inlist');

my %contigs;

######################################################################
# CODE HERE
######################################################################


open(INlist, $inlist) or die("Cannot read file: $inlist\n");
open(INrast, $inrast) or die("Cannot read file: $inrast\n");

open(OUTsub, ">$inrast.sub.txt") or die("Cannot create file: $inrast.sub.txt\n");
print OUTsub "scaffold\tdb.md5.ref\torf.id\tsimilarity\taln.length\te.value\tfunc.annotation\tfunc.category.id\tfunc.hirac.name\n";


while ( my $line = <INlist> ) {
	chomp $line;   	
	$contigs{$line} = 1;
}

close INlist;

while ( my $line = <INrast> ) {
	chomp $line;		
	my @splitline = split("\t",$line);
	my @splitline1 = split("_",$splitline[1]);	
	if (exists($contigs{$splitline1[0]})){
		print OUTsub "$splitline1[0]\t$line\n";
	}
}

close INrast;
close OUTsub;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inlist|l:s", "inrast|r:s");
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
 [-inlist -l]         List of nodes in subgraph to extract.
 [-incrast -r]        Rast onlogy annotation file.
 
=cut