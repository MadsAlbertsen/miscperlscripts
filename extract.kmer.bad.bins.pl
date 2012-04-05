#!/usr/bin/env perl
###############################################################################
#
#	 extract.kmer.bad.bins.pl
#    
#    Looks in classified kmer large contig split files for contigs that are 
#    classified in different groups and output these to a new file.
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

my $inkmer;
my $inbin;
my $outputfile;

$inkmer = &overrideDefault("inkmer.txt",'inkmer');
$inbin = &overrideDefault("inbin.txt",'inbin');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

my $count = 0; 
my $count1 = 0; 
my $countp = 0; 
my $countb = 0; 
my %contigs;
my %bin;

######################################################################
# CODE HERE
######################################################################


open(INbin, $inbin) or die("Cannot read file: $inbin\n");
while ( my $line = <INbin> ) {
	chomp $line; 	
	if ($count > 0){
		my @splitline = split(/\t/, $line);
		my @splitline1 = split(/\./,$splitline[0]);	
		$bin{$splitline[0]} = $splitline[1];
		if (exists($contigs{$splitline1[0]})){		
			if ($contigs{$splitline1[0]} ne $splitline[1]){
				$contigs{$splitline1[0]} = -1;
				$countb++;
			}
		}
		else{
			$contigs{$splitline1[0]} = $splitline[1];
			$countp++;
		}
	}
	$count++;
}

close INbin;
print "$countp different contigs\n";
print "$count different subcontigs\n";
print "$countb contigs with conficting binning\n";

open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
open(OUTall, ">$outputfile.all.tab") or die("Cannot create file: $outputfile.all.tab\n");
open(INkmer, $inkmer) or die("Cannot read file: $inkmer\n");
while ( my $line = <INkmer> ) {
	chomp $line; 	
	if ($count1 > 0){
		my @splitline = split(/\t/, $line);
		my @splitline1 = split(/\./,$splitline[0]);	
		if ($contigs{$splitline1[0]} == -1){				
			print OUT "$line\t$bin{$splitline[0]}\n";
		}
		print OUTall "$line\t$bin{$splitline[0]}\n";	
	}
	else{
		print OUTall "$line\n";
	}
	$count1++;
}
	
close OUT;
close OUTall;
close INkmer;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inbin|b:s", "inkmer|k:s", "outputfile|o:s");
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
 [-inbin -b]          Unscrambler Bin file.
 [-inkmer -k]         Kmer freqeuncy file.
 
=cut