#!/usr/bin/env perl
###############################################################################
#
#    ec.format.db.pl
#
#	 Fast formatting of enzyme nomeclature to tab format..
#    The enzyme.dat and enzclass.txt database was found here :
#    ftp://ftp.ebi.ac.uk/pub/databases/intenz/enzyme
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
my $inclass;
my $outputfile;
my $id;
my $lastone;
my $lasttwo;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$inclass = &overrideDefault("inclass.txt",'inclass');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(INclass, $inclass) or die("Cannot read file: $inclass\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <IN> ) {
	chomp $line;   	
	my @splitline = split(/   /,$line);
	if ($splitline[0] eq "ID"){
		$id = $splitline[1];
	}
	if (($splitline[0] eq "DE") and $id ne ""){
		print OUT "$id\t$splitline[1]\n";
		$id = "";
	}
}

while ( my $line = <INclass> ) {
	chomp $line;  
	if ($line =~ m/\.-/){
		my @splitline = split(/  /,$line);
		my $count = 0;
		while ($splitline[0] =~ m/-/g){$count++;}
		if ($count == 3){
			print OUT "$splitline[0]\t$splitline[1]\n"; 
			$lastone = $splitline[1];
		}
		if ($count == 2){			
			my $outstr = substr($splitline[1],1,length($splitline[1])-1);
			print OUT "$splitline[0]\t$lastone;$outstr\n"; 	
			$lasttwo = $outstr;
		}
		if ($count == 1){			
			print OUT "$splitline[0]\t$lastone;$lasttwo;$splitline[2]\n";			
		}		
		
	}
}

close IN;
close INclass;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "inclass|c:s");
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
 [-inputfile -i]      enzyme.dat
 [-outputfile -o]     Outputfile. 
 [-inclass -c]        enzyclass.txt
 
=cut