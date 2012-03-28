#!/usr/bin/env perl
###############################################################################
#
#    ec.name.to.ec.number.pl
#	 
#    Adds the EC number description to ec numbers. Uses a formated list made 
#    using ec.format.db.pl and all.ec.txt file made using the script
#    mgrast.to.ShotgunFunctionalizeR.pl or in excel...
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
my $inec;
my $outputfile;
my $id;
my %ec;

$inputfile = &overrideDefault("inputfile.txt",'inputfile');
$inec = &overrideDefault("inec.txt",'inec');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

######################################################################
# CODE HERE
######################################################################


open(IN, $inputfile) or die("Cannot read file: $inputfile\n");
open(INec, $inec) or die("Cannot read file: $inputfile\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <INec> ) {
	chomp $line;   
	my @splitline = split(/\t/,$line);
	my $ecn = "EC".$splitline[0];	#To match it with the other file for ShotgunFunctionalizeR
	$ecn =~ s/ //g;
	$ec{$ecn} = $splitline[1];
}

while ( my $line = <IN> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);
	my @splitline1 = split(/ /,$splitline[0]);
	my $count = 0;
	while ($splitline1[0] =~ m/\./g){$count++;}
		if ($count == 1){
			$splitline1[0] = $splitline1[0].".-.-";			
		}
		if ($count == 2){
			$splitline1[0] = $splitline1[0].".-";			
		}	
	if (exists($ec{$splitline1[0]})){
		$splitline[-1] = $ec{$splitline1[0]};
		$splitline[0] = $splitline1[0];
		print OUT join("\t", @splitline), "\n";
	}
	else{
		print OUT "$line\n";
	}
}

close IN;
close INec;
close OUT;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s", "inec|e:s");
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
 [-inputfile -i]      all.ec.txt file. 
 [-outputfile -o]     Outputfile. 
 [-inec -e]           Formated ec name file.
 
=cut