#!/usr/bin/env perl
###############################################################################
#
#    mannotator.totab.add.pl
#
#	 Allows you to add more data points to a tab formated mannotator file.
#	 The extra data must be formatted as: contigid "tab" DATA "tab" DATA    
#    Usefull to add e.g. coverage or binning information to all contigs
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

my $manfile;
my $edatafile;
my $outfile;

$manfile = &overrideDefault("manfile.gff",'manfile');
$edatafile = &overrideDefault("data.tab",'edatafile');
$outfile = &overrideDefault("outfile.txt",'outfile');

my $line;
my $empty;
my $elements;
my $count = 0;
my $count1 = 0;
my @splitline;
my %contig;

######################################################################
# CODE HERE
######################################################################

open(IN1, $manfile) or die("Cannot open $manfile\n");
open(IN2, $edatafile) or die("Cannot open $edatafile\n");
open(OUT, ">$outfile") or die("Cannot create $outfile\n");

################### Read file with new data and hash based on contig nr. must be in the format contigid	DATA	DATA
while ( $line = <IN2> ) {
	$count++;
	chomp $line;
		@splitline = split(/\t/,$line);
		my $ID = $splitline[0];
		shift @splitline;
		$contig{$ID} = join("\t",@splitline);
		$elements = scalar @splitline;	
}

foreach my $temp (@splitline){
	$empty = $empty."\t0";
}

while ( $line = <IN1> ) {
	chomp $line;	
	@splitline = split(/\t/,$line);
	my $ID = $splitline[0];
	if (exists($contig{$ID})){
		print OUT "$line\t$contig{$ID}\n";
	}
	else{
		print OUT "$line$empty\n";
	}
}

print "done.\n";

close IN1;
close IN2;
close OUT;

exit;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "manfile|m:s", "edatafile|e:s", "outfile|o:s");
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

    mannotator.totab.add.pl

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

   Allows you to add more data points to a tab formated mannotator file.
   The extra data must be formatted as: contigid "tab" DATA "tab" DATA    
   Usefull to add e.g. coverage or binning information to all contigs

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-manfile -m]        tab formated mannotator file.
 [-edatafile -e]      tab formated extra data file. First column must be contig id.
 [-outfile -m]        Outfile.
 
=cut