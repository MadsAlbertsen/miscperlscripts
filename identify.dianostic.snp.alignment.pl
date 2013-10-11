#!/usr/bin/env perl
###############################################################################
#
#    Identifies diagnostic SNPs in alligned sequences in fasta format.
#
#    Copyright (C) 2013 Mads Albertsen
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

my $infasta;
my $outputfile;
my $insam;

$infasta = &overrideDefault("aligned.fasta",'infasta');
$insam = &overrideDefault("1",'insam');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my %seqs;
my $header;
my %cons;
my $count2;
my %dSNP;
my %coverage;

######################################################################
# CODE HERE
######################################################################


open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
open(INfasta, "$infasta") or die("Cannot read file: $infasta\n");

while ( my $line = <INfasta> ) {
	$line =~ s/\r\n//g;
	if ($line =~ m/>/) {
		$line =~ s/>//; 
		$header = $line;	
	}	
	else {		
		$seqs{$header} = $line;
	}
}	

for (my $count = 0; $count < length($seqs{$header}); $count++){
	$cons{$count}{A} = 0;
	$cons{$count}{T} = 0;
	$cons{$count}{C} = 0;
	$cons{$count}{G} = 0;
	$count2 = $count;
	foreach my $gene (keys %seqs){
		$cons{$count}{substr($seqs{$gene}, $count, 1)}++;		
	}
}

close INfasta;

open(INsam, "$insam") or die("Cannot read file: $insam\n");

if ($insam ne "1"){
	while ( my $line = <INsam> ) {
	chomp $line;   	
		if ($line !~ m/(\@PG|\@HD|\@SQ|\@RG)/) { 
			my @readinfo = split(/\t/,$line);
			for (my $count = $readinfo[3]; $count < ($readinfo[3] + length($readinfo[9])); $count++){	
				if (exists($coverage{$readinfo[2]}{$count})){
					$coverage{$readinfo[2]}{$count}++;
				}
				else{
					$coverage{$readinfo[2]}{$count} = 1;
				}
			}
		}
	}	
close INsam;
}

foreach my $gene (sort keys %coverage)
{
   my %innerhash = %{ $coverage{$gene} };  # <---- note %{} cast
   foreach my $pos (sort {$a <=> $b} keys %innerhash){
      print "$gene $pos $coverage{$gene}{$pos}\n";
   }
}


print OUT "gene\tpos\tsnp\n";

foreach my $gene (sort keys %seqs){
	for (my $count = 0; $count < length($seqs{$gene}); $count++){		
		my $SNP = substr($seqs{$gene}, $count, 1);
		if ( $cons{$count}{$SNP} == 1 ){	
			my $cov = 0;
			if (exists($coverage{$gene}{$count})){
				$cov = $coverage{$gene}{$count};
			}
			print OUT "$gene\t$count\t$SNP\t$cov\n";
			$dSNP{$gene}{$count} = 1;
		}
	}
}

close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "infasta|i:s", "outputfile|o:s", "insam|s:s");
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
 [-infasta -i]        Input aligned fasta file.
 [-insam -s]          Input sam file (optional).
 [-outputfile -o]     Outputfile.
 
=cut