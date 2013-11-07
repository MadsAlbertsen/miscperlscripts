#!/usr/bin/env perl
###############################################################################
#
#    mp.fix.FR.single.to.RF.pl
#
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

my $inputfile;

$inputfile = &overrideDefault("single.fa",'inputfile');

my $line;
my $linenr = 0;
my $header;
my %read1;
my %read2;
my $seq;


######################################################################
# CODE HERE
######################################################################

open(IN, $inputfile) or die("Cannot open $inputfile\n");
open(OUT, ">paired.fa") or die("Cannot create paired.fa\n");

while ( my $line = <IN> ) {
	chomp $line; 
	$linenr++;
	if ($line =~ m/>/) {
		if ($linenr != 1){
			my @splitline = split(/_/, $header);
			if ($header =~ m/_1/) {
				$read1{$splitline[0]} = $header."\t".$seq;
			}
			else{
				$read2{$splitline[0]} = $header."\t".$seq;
			}
		}
		$header = $line;
		$seq = "";
	}
	else{
		$seq = $seq.$line;
	}
}

my @splitline = split(/_/, $header);
if ($header =~ m/_1/) {
	$read1{$splitline[0]} = $header."\t".$seq;
}
else{
	$read2{$splitline[0]} = $header."\t".$seq;
}

foreach my $key (keys %read1){
	if (exists($read2{$key})){
		my @split1 = split(/\t/,$read1{$key});		
		$split1[1] = reverse($split1[1]);
		$split1[1] =~ tr/ACGTacgt/TGCAtgca/;
		print OUT "$split1[0]\n$split1[1]\n";
		my @split2 = split(/\t/,$read2{$key});
		$split2[1] = reverse($split2[1]);
		$split2[1] =~ tr/ACGTacgt/TGCAtgca/;
		print OUT "$split2[0]\n$split2[1]\n";
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
    my @standard_options = ( "help|h+", "inputfile|i:s");
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

    mp.fix.FR.single.to.RF.pl

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

	Splits a merged fastq file.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]           Displays this basic usage information
 [-inputfile -i]      Input combined pe fastq file.
 
=cut
