#!/usr/bin/env perl
###############################################################################
#
#    rna.seq.to.stranded.pl
#
#	 Makes a SAM file of stranded RNAseq CLC data - stranded..
#    Outputs a simple tab - seperated file.
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

my $insam;
my $outputfile;

$insam = &overrideDefault("insam.sam",'insam');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my %length;
my %sense;
my %antisense;

######################################################################
# CODE HERE
######################################################################


open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
open(INsam, "$insam") or die("Cannot read file: $insam\n");

while ( my $line = <INsam> ) {
	chomp $line;   	
	if ($line =~ m/\@SQ/) {
		my @splitline = split(/\t/,$line);
		my @contigname = split(/:/, $splitline[1]);                     												  #Retrive the contig name
		my @contiglength = split(/:/, $splitline[2]);																	  #Retrive the contig length
		$length{$contigname[1]} = $contiglength[1];                   												  #store it
		$sense{$contigname[1]} = 0;
		$antisense{$contigname[1]} = 0;
		}	
	else {
		if ($line !~ m/(\@PG|\@HD|\@SQ|\@RG)/) { 
			my @readinfo = split(/\t/,$line);
			if ($readinfo[1] == 16){
				$sense{$readinfo[2]}++;
			}
			else{
				if ($readinfo[1] == 0){
					$antisense{$readinfo[2]}++;
				}
				else{
					print "Problematic SAM flag: $line\n";
				}
			}
			
		}
	}	
}

print OUT "Gene\tLength\tSense\tAntisense\n";
foreach my $gene (keys %length){
	print OUT "$gene\t$length{$gene}\t$sense{$gene}\t$antisense{$gene}\n";
}

close INsam;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "insam|s:s", "outputfile|o:s");
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
 [-insam -s]          Input sam file.
 [-outputfile -o]     Outputfile.
 
=cut