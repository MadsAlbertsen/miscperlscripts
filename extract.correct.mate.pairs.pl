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
my $endlength;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$endlength = &overrideDefault(3000,'endlength');

my %reads;
my %contigs;
my $progress = 0;
my $mpcount = 0;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT1, ">p1.fa") or die("Cannot create file: p1.fa\n");
open(OUT2, ">p2.fa") or die("Cannot create file: p2.fa\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	my @splitline = split(/\t/, $line); 	
	my $test = length($splitline[9]);
	if ($line =~ m/\@SQ/) {                                                                                                                          #Get the lenfth of each scaffold and store it in an array                     												                  
			my @contigname = split(/:/, $splitline[1]);                     												  
			my @contiglength = split(/:/, $splitline[2]);																	  
			$contigs{$contigname[1]} = $contiglength[1];                   												  
		}	
	else {
		if ($line !~ m/(\@PG|\@HD|\@SQ)/) {                                                                                                          #If we are not in the header region
			if ( ($contigs{$splitline[2]}-$splitline[3] - length($splitline[9]) < $endlength) or ($splitline[3] < $endlength) ){                     #Check if the read map in one of the ends of the scaffolds
				my @header = split(/_/,$splitline[0]);
				if (exists($reads{$header[0]})){                                                                                                     #Check if the other pair of the read have been seen before
					my @oldread = split(/\t/,$reads{$header[0]});				
					if ($oldread[1] ne $splitline[2]){                                                                                               #Check if the two reads map to different scaffolds
						my @readpair = split(/:/,$header[1]);
						$mpcount++;
						if ($readpair[0] == 1){                                                                                                      #Print the reads to the right file
							print OUT1 ">$splitline[0]\n"; 
							print OUT1 ">$splitline[9]\n"; 						
							print OUT2 ">$oldread[0]\n"; 
							print OUT2 ">$oldread[2]\n"; 
						}
						else{
							print OUT2 ">$splitline[0]\n"; 
							print OUT2 ">$splitline[9]\n"; 
							print OUT1 ">$oldread[0]\n"; 
							print OUT1 ">$oldread[2]\n"; 
					
						}
					}
				}
				else{
					$reads{$header[0]} = "$splitline[0]\t$splitline[2]\t$splitline[9]";
				}
			}
			$progress++;
			if ($progress == 1000000){
				print "$progress reads processed\n";
				$progress = 0;
			}
		}
	}
}

print "$progress reads processed\n";
print "$mpcount mate-pairs extracted\n";

close IN;
close OUT1;
close OUT2;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "endlength|e:s");
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

    extract.correct.mate.pairs.pl

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

extract.correct.mate.pairs.pl  -i [-h -e]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Inputfile. 
 [-endlength -e]      Output reads X bp from the ends (default: 3000)
 
=cut