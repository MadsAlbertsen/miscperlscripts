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

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

print OUT "Type\tStart\tEnd\tStrand\tTag\tGene\tECnumber\tProduct\n";

while ( my $line = <IN> ) {
	chomp $line;
	my @info = split(/\t/, $line);
	next if ($info[2] =~ m/Source/);
	next if ($info[2] =~ m/Gene/);
	
	my @details = split(";",$info[8]);

	my $locus = "NA";
	my $gene = "NA";	
	if ($details[0] =~ m/locus/){
		my @details2 = split(" ", $details[0]);
		$locus = $details2[1];		
	}
	else{
		my @split1 = split(" ; locus_tag ", $info[8]);
		my @split2 = split(" ; ", $split1[1]);
		$locus = $split2[0];
		my @details2 = split(" ", $details[0]);
		$gene = $details2[1];
	} 

	my $ec = "NA";
	if ($info[8] =~ m/ ; EC_number /){
		my @split1 = split(" ; EC_number ", $info[8]);
		my @split2 = split(" ; ", $split1[1]);
		$ec = $split2[0];
	}	
	
	my $product = "NA";
	if ($info[8] =~ m/ ; product /){
		my @split1 = split(" ; product ", $info[8]);
		my @split2 = split(" ; ", $split1[1]);
		$product = $split2[0];
		$product =~ s/"//g; 		
	}	
	
	print OUT "$info[2]\t$info[3]\t$info[4]\t$info[6]\t$locus\t$gene\t$ec\t$product\n";
	
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
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s");
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
 
=cut
