#!/usr/bin/env perl
###############################################################################
#
#    calc.adjusted.coverage.in.samfile.pl
#
#	 Calculates median coverage in a given SAM file. It assumes that contigs
#    /scaffolds are arranged one after another. E.g. all reads to contig X
#    then next contig.
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
my $minlength;


$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$minlength = &overrideDefault("0",'minlength');

my %clength;
my %ccov;
my $contig = "contig";
my $prevcontig = "prevcontig";
my $ccount = 0;
my $scount = 0;
my $scount2 = 0;
my $totalreads = 0;
my $totalbases = 0;
my $tcount = 0;
my $countpos = 0;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
print OUT "scaffold\tavg.cov\tstd.dev.\tmedian.cov\n";


while ( my $line = <IN> ) {
	chomp $line;                                                         												     
	my @splitline = split(/\t/, $line); 	
	if ($line =~ m/\@SQ/) {                               										                      #if we are in the contig header area then retrive all contigs/scaffolds and store the name and length in the hash: contig		
		my @contigname = split(/:/, $splitline[1]);                     										      #Retrive the contig name
		my @contiglength = split(/:/, $splitline[2]);																  #Retrive the contig length
		$clength{$contigname[1]} = $contiglength[1];                   												  #Make a hash with key = "contig name" and value = "contig length"			
	}
	else {
		if ($line !~ m/(\@PG|\@HD|\@SQ)/) { 
			$contig = $splitline[2];		
			if ($ccount == 0){
				for (my $count = 1; $count <= $clength{$contig}; $count++) {
					$ccov{$count} = 0;
				}
			}
			if (($contig eq $prevcontig) or ($ccount == 0)){
				my $readlength = length($splitline[9]);		
				if ($readlength >= $minlength){ 				;
					$totalbases += $readlength;
					for (my $count = $splitline[3]; $count < ($splitline[3]+$readlength); $count++) {					
						$tcount++;				
						$ccov{$count}++;
					}
					$tcount = 0;
				}
			}
			else{				                                                                                                  #calculate stats here and write to a file!
				my $avg = $totalbases/$clength{$prevcontig};
				my $covpos = $clength{$prevcontig};
				if (my $is_even = $covpos % 2 == 0){                                                                               #To be able to get a better estimate of where the read maps in the start and end / otherwise it would just have used the start position
					$covpos = $covpos/2;
				}
				else{
					$covpos = ($covpos+1)/2;
				}
				$countpos = 0;
				my $median = 0;
				foreach my $key (sort { $ccov{$a} <=> $ccov{$b} } keys %ccov){
					$countpos++;
					if ($countpos == $covpos){
						$median = $ccov{$key}						
					}					
				}
				print OUT "$prevcontig\t$clength{$prevcontig}\t",sprintf("%.3f",$avg),"\t$median\n";
				%ccov = ();
				#To catch the new sequence				
				my $readlength = length($splitline[9]);				 				
				$totalbases = $readlength;
				for (my $count = 1; $count <= $clength{$contig}; $count++) {
					$ccov{$count} = 0;
				}
				if ($readlength >= $minlength){ 
					for (my $count = $splitline[3]; $count < ($splitline[3]+$readlength); $count++) {					
						$tcount++;				
						$ccov{$count}++;
					}	
				}
				$tcount = 0;
				$scount++;
				$scount2++;
				if ($scount2 == 100){
					print "$scount scaffolds evaluated\n";
					$scount2 = 0;
				}
			}
			$prevcontig = $contig;
			$ccount++;
		}
	}
}
my $avg = $totalbases/$clength{$contig}; #To catch the last scaffold
my $covpos = scalar keys %ccov;
my $poswcov = $covpos;
if (my $is_even = $covpos % 2 == 0){                                                                              
	$covpos = $covpos/2;
}
else{
	$covpos = ($covpos+1)/2;
}
$countpos = 0;
my $median = 0;
foreach my $key (sort { $ccov{$a} <=> $ccov{$b} } keys %ccov){
	$countpos++;
	if ($countpos == $covpos){
		$median = $ccov{$key}						
	}					
}
print OUT "$prevcontig\t$clength{$prevcontig}\t",sprintf("%.3f",$avg),"\t$median\n";
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
 [-inputfile -i]      In SAM file. 
 [-outputfile -o]     Outputfile. 
 [-minlength -m]      Minumum read length to use in calculations.
 
=cut