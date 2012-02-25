#!/usr/bin/env perl
###############################################################################
#
#    mannotator.totab.pl
#
#	 Converts the mannotator gff file into tab format. Also splits coulmns with
#    multiple entries and arranges all unique entires in a column each.
#    Identifies "=" as definition field and ; in the ontology field
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

my $manfile;
my $outfile;

$manfile = &overrideDefault("manfile.gff",'manfile');
$outfile = &overrideDefault("outfile.tab",'outfile');

my $line;
my $count;
my @splitline1;
my @splitline2;
my @splitline3;
my @splitline4;
my @splitline5;
my %cats;

######################################################################
# CODE HERE
######################################################################

open(IN, $manfile) or die("Cannot open $manfile\n");
open(OUT, ">$outfile") or die("Cannot create $outfile\n");

################### Read categories into HASH (yeps reads the whole file... in order to make it generic..)
while ( $line = <IN> ) {
	chomp $line;	
	$count++;
	if ($count > 1){
		@splitline1 = split(/\t/,$line);
		@splitline2 = split(/;/,$splitline1[8]);                      #where the extra cats are not defined by = are! = not generic afterall..
		foreach my $id (@splitline2){
			@splitline3 = split(/=/,$id);
			$cats{$splitline3[0]} = "";
			if ($splitline3[0] eq "Ontology_term"){				
				@splitline4 = split(/ /,$splitline3[1]);				
				foreach my $id1 (@splitline4){
					@splitline5 = split(/:/,$id1);
					$cats{$splitline5[0]} = "";
				}
			}
		}
	}
}
my @outcats1 = keys %cats;
my $outstring = join("\t",@outcats1);
print OUT "Contig\tGenecaller\tCDS\tstart\tend\trandom1\tstrand\trandom2\t$outstring\n";	

seek (IN,0,0);

$count = 0;
while ( $line = <IN> ) {
	chomp $line;	
	$count++;
	if ($count > 1){
		@splitline1 = split(/\t/,$line);
		@splitline2 = split(/;/,$splitline1[8]); #where the extra splits are!
		foreach my $id (@splitline2){
			@splitline3 = split(/=/,$id);
			$cats{$splitline3[0]} = $splitline3[1];
			if ($splitline3[0] eq "Ontology_term"){
				@splitline4 = split(/ /,$splitline3[1]);
				foreach my $id1 (@splitline4){
					@splitline5 = split(/:/,$id1);
					$cats{$splitline5[0]} = $id1;					
				}
			}
		}
		my @outcats = keys %cats;
		pop @splitline1; #remove the ; seperated field
		foreach my $tempout (@outcats){
			push (@splitline1, $cats{$tempout}); #should add an empty field if not 	
			$cats{$tempout} = "";
		}	
		my $outstring = join("\t",@splitline1);
		print OUT "$outstring\n";		
	}
}

print "done.\n";

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
    my @standard_options = ( "help|h+", "manfile|i:s", "outfile|o:s");
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

 [-help -h]           Displays this basic usage information.
 [-manfile -i]        Input mannotator gff file. 
 [-outfile -o]        Output tab file. 
 
=cut
