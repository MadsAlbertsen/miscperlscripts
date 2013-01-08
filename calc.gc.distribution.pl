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

my $inputfile;
my $outputfile;
my $filetype;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$filetype = &overrideDefault(0,'filetype');                #0 = fasta


my $lineext = 2;
my $linecount = 0;
my $readcount = 0;
my $length = 0;
my %A;
my %T;
my %C;
my %G;

 

######################################################################
# CODE HERE
######################################################################

if ($filetype == 1){
	$lineext = 4;
	$linecount = 2;
}

open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN> ) {
	chomp $line;   		
	$linecount++;
	if ($linecount == $lineext){
		my @splitline = split(//,$line);
		$length = 0;
		foreach my $nucl (@splitline){
			$length++;
			if ($nucl eq "A"){
				if (exists $A{$length}){
					$A{$length}++;
				}
				else{
					$A{$length} = 1;
				}
			}
			if ($nucl eq "T"){
				if (exists $T{$length}){
					$T{$length}++;
				}
				else{
					$T{$length} = 1;
				}	
			}
			if ($nucl eq "C"){
				if (exists $C{$length}){
					$C{$length}++;
				}
				else{
					$C{$length} = 1;
				}	
			}
			if ($nucl eq "G"){
				if (exists $G{$length}){
					$G{$length}++;
				}
				else{
					$G{$length} = 1;
				}								
			}
		}
		$linecount = 0;
	}	
}

for (my $count = 1; $count <= $length; $count++)  {
      if (!exists($A{$count})){
		$A{$count} = 0;
	  }
      if (!exists($T{$count})){
		$T{$count} = 0;
	  }
	  if (!exists($C{$count})){
		$C{$count} = 0;
	  }
      if (!exists($G{$count})){
		$G{$count} = 0;
	  }	  
	  print "$count $A{$count} $T{$count} $C{$count} $G{$count}\n";	  
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s","filetype|q:+");
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
 [-inputfile -i]      Inputfile. 
 [-outputfile -o]      Outputfile. 
 [-filetype -q]       Fasta or fastq input (flag, default fasta)
 
=cut