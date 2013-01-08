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
my $noNA;
my $outlegend;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
$outlegend = &overrideDefault("outlegend.txt",'outlegend');
$noNA = &overrideDefault(0,'noNA');

my %contigp;
my %color;

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
open(OUT2, ">$outlegend") or die("Cannot create file: $outlegend\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);	
	my @splitline1 = split(/;/,$splitline[1]);
	my @splitline2 = split(/_/,$splitline[0]);
	if (!exists($contigp{$splitline2[-4]})){
		if (exists($splitline1[3])){
			$contigp{$splitline2[-5]} = "$splitline1[3]"; 
			$color{$splitline1[3]}++
		}
		else{
			$contigp{$splitline2[-5]} = "NA";
		}
	}
	else{
		if (exists($splitline1[3])){
			$contigp{$splitline2[-5]} = "$contigp{$splitline2[-5]};$splitline1[3]";
			$color{$splitline1[3]}++
		}
		else{
			$contigp{$splitline2[-5]} = "$contigp{$splitline2[-5]};NA";
		}
	}
}

my $colorcount = 0;
my $taxcolor;
print OUT2 "x\ty\tlegend\tcolor\n";

foreach my $key (sort { $color{$b} <=> $color{$a} } keys %color){
	$colorcount++;
	if ($colorcount < 12){
		$color{$key} = $colorcount;	
		print OUT2 "0\t$colorcount\t$key\t$colorcount\n";#HERE
	}
}
$colorcount++;
if ($colorcount < 12){
	print OUT2 "0\t$colorcount\tOther\t12\n";
}
else{
	print OUT2 "0\t12\tOther\t12\n";
}

close OUT2;

foreach my $key (keys %contigp){
	my @splitline = split(/;/, $contigp{$key});
	my %taxcons;
	foreach my $key2 (@splitline){
		$taxcons{$key2}++;
	}
	if ($noNA == 1){
		$taxcons{"NA"} = 0;                             #Better to just destroy the hash key..
	}
	my $count = 0;
	my $temptax;
	my $tempcount;	
	my $printed = 0;
	foreach my $key3 (sort { $taxcons{$b} <=> $taxcons{$a} } keys %taxcons){
		$count++;
		if ($count == 2){
			if ($taxcons{$key3} == $tempcount){	
				if ($noNA == 0){
					print OUT "$key\tNA\t12\t$contigp{$key}\n";
				}
			}
			else{
				if (exists($color{$temptax})){
					$taxcolor = $color{$temptax};
				}
				else{
					$taxcolor = 12;
				}
				print OUT "$key\t$temptax\t$taxcolor\t$contigp{$key}\n";
			}
		$printed = 1;
		}
		$temptax = $key3;
		$tempcount = $taxcons{$key3};
	}
	if ($printed == 0){
		if (exists($color{$temptax})){
			$taxcolor = $color{$temptax};
			}
			else{
				$taxcolor = 12;
			}
		if ($noNA == 0){	
			print OUT "$key\t$temptax\t$taxcolor\t$contigp{$key}\n";
		}
		else{
			if ($temptax ne "NA"){
				print OUT "$key\t$temptax\t$taxcolor\t$contigp{$key}\n";
			}
		}
	}
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "outlegend|l:s", "noNA|n:+");
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
 [-inputfile -i]      Inputfile 
 [-outputfile -o]     Out data 
 [-outlegend -l]      Out legend data
 [-noNA -n]           Ignore ambigous assignments (flag, default no).
 
=cut