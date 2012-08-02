#!/usr/bin/env perl
###############################################################################
#
#    img.annotations.to.pivot.pl
#
#	 Converts IMG annotation tab tile to format readily used in pivot tables
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

$inputfile = &overrideDefault("img.annotations.tab",'inputfile');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my $count = 0;
my $gene = "";
my $locus = "";
my $product = "";
my $dna = "";
my $aa = "";
my $cog = "";
my $cogname = "";
my $cogeval = "";
my $pfam = "";
my $pfamname = "";
my $pfameval = "";
my $tigr = "";
my $tigrname = "";
my $tigreval = "";
my $ec = "";
my $ecname = "";
my $ko = "";
my $koname = "";


######################################################################
# CODE HERE
######################################################################

	
open(IN, $inputfile) or die;
open(OUT, ">$outputfile") or die;


while (my $line = <IN>)  {
	$count++;
	if ($count > 1){
		my @splitline = split(/\t/,$line);
		if ($splitline[2] eq "Product_name"){
			$gene = $splitline[0];
			$locus = $splitline[1];
			$product = $splitline[4];
		}
		if ($splitline[2] eq "DNA_length"){
			my @sl = split(/bp/,$splitline[4]);
			$dna = $sl[0];
		}
		if ($splitline[2] eq "Protein_length"){
			my @sl = split(/aa/,$splitline[4]);
			$aa = $sl[0];
		}	
		if ($splitline[2] =~ m/COG/) {
			if ($cog eq ""){
				$cog = $splitline[2];
				$cogname = $splitline[3];
				$cogeval = $splitline[5];
				chomp $cogeval;
			}
			else{
				chomp $splitline[5];
				if ($cogeval > $splitline[5]){
					$cog = $splitline[2];				
					$cogname = $splitline[3];
					$cogeval = $splitline[5];
				}
			}			
		}			
		if ($splitline[2] =~ m/pfam/) {
			if ($pfam eq ""){
				$pfam = $splitline[2];
				$pfamname = $splitline[3];
				$pfameval = $splitline[5];
				chomp $pfameval;
			}
			else{
				chomp $splitline[5];
				if ($pfameval > $splitline[5]){
					$pfam = $splitline[2];				
					$pfamname = $splitline[3];
					$pfameval = $splitline[5];
				}
			}
			
		}
		if ($splitline[2] =~ m/TIGR/) {
			if ($tigr eq ""){
				$tigr = $splitline[2];
				$tigrname = $splitline[3];
				$tigreval = $splitline[5];
				chomp $tigreval;
			}
			else{
				chomp $splitline[5];
				if ($tigreval > $splitline[5]){
					$tigr = $splitline[2];				
					$tigrname = $splitline[3];
					$tigreval = $splitline[5];
				}
			}
			
		}				
		if ($splitline[2] =~ m/EC/) {
				$ec = $splitline[2];
				$ecname = $splitline[3];
		}		
		if ($splitline[2] =~ m/KO/) {
				$ko = $splitline[2];
				$koname = $splitline[3];
		}		
				
		if ($splitline[0] eq ""){
			print OUT "$gene\t$locus\t$product\t$dna\t$aa\t$cog\t$cogname\t$cogeval\t$pfam\t$pfamname\t$pfameval\t$tigr\t$tigrname\t$tigreval\t$ec\t$ecname\t$ko\t$koname\n";
			$gene = "";
			$locus = "";
			$product = "";
			$dna = "";
			$aa = "";		
			$cog = "";
			$cogname = "";
			$cogeval = "";
			$pfam = "";
			$pfamname = "";
			$pfameval = "";
			$tigr = "";
			$tigrname = "";
			$tigreval = "";			
			$ec = "";
			$ecname = "";
			$ko = "";
			$koname = "";			
		}		
	}
	else{
		print OUT "gene.oid\tlocus.tag\tproduct.name\tdna.length\tprotein.length\tcog\tcog.name\tcog.eval\tpfam\tpfam.name\tpfam.eval\ttigr\ttigr.name\ttigr.eval\tec\tec.name\tko\tko.name\n";
	}

}

close IN;
close OUT;
exit;

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

    calc.gc.pl

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

	Calculates gc content in fastafiles.

=head1 SYNOPSIS

script.pl  -i -o [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input fasta file. 
 [-outputfile -o]     Outputfile.
 
=cut