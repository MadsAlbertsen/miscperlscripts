#!/usr/bin/env perl
###############################################################################
#
#    esom.classified.to.contigs.pl
#
#	 Renames sub.contigs from esom using a name file that links the original
#    contig name to the esom name.
#
#    ToDo: split the original contig file based on majority assignments or 
#          just add bins as 3.5 when the sub.contigs are in bin 3 and 5 
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

my $inclass;
my $innames;
my $outputfile;

$inclass = &overrideDefault("inclass.cls",'inclass');
$innames = &overrideDefault("innames.txt",'innames');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my %class;
 
######################################################################
# CODE HERE
######################################################################


open(INclass, $inclass) or die("Cannot read file: $inclass\n");

while ( my $line = <INclass> ) {
	chomp $line;   	
	if ($line !~ m/\%/) { 
		my @splitline = split(/\t/,$line);
		$class{$splitline[0]} = $splitline[1];
	}
}
close INclass;

open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
print OUT "contig\tbin\tesom.name\n";
open(INnames, $innames) or die("Cannot read file: $innames\n");

while ( my $line = <INnames> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);
	my @splitline1 = split(/_/,$splitline[1]);
	if (exists($class{$splitline1[0]})){
		print OUT "$splitline[1]\t$class{$splitline1[0]}\t$splitline[0]\n";
	}
	else{
		print "Couldn not find any class for $splitline[0] from the entry $line.\n";
	}
}
close INnames;

close OUT;


######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inclass|c:s", "innames|n:s", "outputfile|o:s");
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

 [-help -h]            Displays this basic usage information
 [-inclass -c]         Class file.
 [-innames -n]         Names file.
 [-outputfile -o]      Outputfile. 
 
=cut