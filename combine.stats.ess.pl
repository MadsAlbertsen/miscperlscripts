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

my $instats;
my $iness;
my $ingc;
my $inkmer;
my $outputfile;

$instats = &overrideDefault("instats.txt",'instats');
$iness = &overrideDefault("iness.txt",'iness');
$ingc = &overrideDefault("ingc.txt",'ingc');
$inkmer = &overrideDefault("inkmer.txt",'inkmer');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my %length;
my %coverage;
my %ess;
my %esscolor;
my %essfull;
my %gc;
my %kmer;
my $kmerheader;
my $count = 0;
 
######################################################################
# CODE HERE
######################################################################


open(INstats, $instats) or die("Cannot read file: $instats\n");
while ( my $line = <INstats> ) {
	$count++;
	if ($count != 1){
		chomp $line;   	
		$line =~ s/"//g;
		my @splitline = split(/,/,$line);
		my @splitline1 = split(/ /, $splitline[0]);
		$length{$splitline1[-2]} = $splitline[1];
		$coverage{$splitline1[-2]} = $splitline[5]
	}
}
close INstats;

open(INess, $iness) or die("Cannot read file: $iness\n");
while ( my $line = <INess> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);
	$ess{$splitline[0]} = $splitline[1];
	$esscolor{$splitline[0]} = $splitline[2];
	$essfull{$splitline[0]} = $splitline[3];
}
close INess;

open(INgc, $ingc) or die("Cannot read file: $ingc\n");
while ( my $line = <INgc> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);
	my @splitline1 = split(/_/,$splitline[0]);
	$gc{$splitline1[-1]} = $splitline[1];
}
close INgc;

open(INkmer, $inkmer) or die("Cannot read file: $inkmer\n");
$count = 0;
while ( my $line = <INkmer> ) {
	$count++;
	if ($count != 1){
		chomp $line;   	
		my @splitline = split(/\t/,$line);
		my @splitline1 = split(/_/,$splitline[0]);
		shift @splitline;
		$kmer{$splitline1[-1]} = join("\t",@splitline);
	}
	else{
		my @splitline = split(/\t/,$line);
		shift @splitline;
		$kmerheader = join("\t",@splitline);
	}
}
close INkmer;

open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");
print OUT "conting\tlength\tcoverage\tgc\tess.assignment\tess.color\ttess.fullpath\t$kmerheader";
foreach my $key (sort {$a  <=>  $b} keys %length){
	if (!exists($ess{$key})){
		$ess{$key} = "";
		$essfull{$key} = "";
		$esscolor{$key} = "";
	}
	if (!exists($kmer{$key})){
		$kmer{$key} = "";
	}	
	print OUT "$key\t$length{$key}\t$coverage{$key}\t$gc{$key}\t$ess{$key}\t$esscolor{$key}\t$essfull{$key}\t$kmer{$key}\n";
}
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "instats|s:s", "iness|e:s", "ingc|g:s", "inkmer|k:s", "outputfile|o:s");
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
 [-instats -s]        Statsfile
 [-iness -e]          Essential file
 [-ingc -g]           Gc file
 [-inkmer -k]         Kmer file
 [-outputfile -o]     Outputfile 
 
=cut