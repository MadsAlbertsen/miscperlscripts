#!/usr/bin/env perl
###############################################################################
#
#    find.lost.indexes.pl
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
#use strict;
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
my $inlist;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$inlist = &overrideDefault("inlist.txt",'inlist');
 
my $count = 0;
my $newkey = 0;
my %index;
my %outkey;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

if ($inlist ne "inlist.txt"){
	open(INlist, $inlist) or die("Cannot read file: $inputfile\n");
		while ( my $line = <INlist> ) {
		chomp $line; 	
		$outkey{$line} = 1;
		open($line, ">$line.fastq") or die("Cannot create file: $inlist\n");
		}
	close INlist;
}


while ( my $line = <IN> ) {
	chomp $line; 
	$count++;
	if ($count == 1){
		my @splitline = split(/:/,$line);
		my @splitline2 = split(/ /,$splitline[-4]);
		$newkey = "$splitline[1].$splitline2[1].$splitline[3].$splitline[-1]";
		if (exists $index{$newkey}){
			$index{$newkey}++;
		}
		else{
			$index{$newkey} = 1;
		}
	}
	else{
		if ($count ==4){
			$count = 0;
		}
	}
	if (exists $outkey{$newkey}){
		print $newkey "$line\n";
	}
}

print OUT "Run.Lane.Read.Barcode\tCount\n";
foreach my $key (sort { $index{$b} <=> $index{$a} } keys %index){
	print OUT "$key\t$index{$key}\n";
}

close IN;
close OUT;

if ($inlist ne "inlist.txt"){
	open(INlist, $inlist) or die("Cannot read file: $inputfile\n");
	while ( my $line = <INlist> ) {
		chomp $line; 	
		close $line;
		}
	close INlist;
}



######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s","inlist|l:s");
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

find.lost.indexes.pl  -i [-o -l -h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Inputfile of undetermined reads. 
 [-outputfile -o]     Overview of barcodes in the list. 
 [-inlist -l]         List of barcodes to extract to new files.
 
=cut