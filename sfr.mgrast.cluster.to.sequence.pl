#!/usr/bin/env perl
###############################################################################
#
#    mgrast.cluster.to.sequence.pl
#
#	 Deconvolutes the mg.rast cluster back to sequences. Input mg.rast
#    cluster file and any annotated mg.rast file
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

my $incluster;
my $inannotation;
my $outputfile;

$incluster = &overrideDefault("mg.rast.cluster.txt",'incluster');
$inannotation = &overrideDefault("mg.rast.annotation.txt",'inannotation');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 
my $ccontig;
my %cluster;

######################################################################
# CODE HERE
######################################################################


open(INcluster, $incluster) or die("Cannot read file: $incluster\n");
open(INannotation, $inannotation) or die("Cannot read file: $inannotation\n");
open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");

while ( my $line = <INcluster> ) {
	chomp $line;   	
	my @splitline = split(/\t/,$line);
	my $centry = $splitline[0];
	my @splitline1 = split(/,/,$splitline[2]);
	$ccontig = $splitline[1];
	foreach my $contig (sort @splitline1){
		$ccontig = $ccontig."\t".$contig;
	}
	$cluster{$centry} = $ccontig;		
}

while ( my $line = <INannotation> ) {
	chomp $line;
	my @splitline = split(/\t/,$line);
	if (exists $cluster{$splitline[1]}){                                                           #If the sequences are clustered then decluster by using the information loaded in the cluster file
		my @splitline1 = split(/\t/,$cluster{$splitline[1]});
		foreach my $contig (@splitline1){
			$splitline[1] = $contig;
			print OUT join("\t", @splitline), "\n";
		}
	}
	else{
		print OUT "$line\n"
	}
}

close INcluster;
close INannotation;
close OUT;

open(INout, "$outputfile") or die("Cannot open file: $outputfile\n");                              #This could just be done under the 1st readthrough - but it is done in 2 passes to make it more readable

my %ko;
my %subsystems;
my %cog;
my %ec;
my %go;
my %ecfound;
my %koh;
my %subsystemsh;
my %cogh;
my %ech;
my %goh;

open(OUTko, ">$outputfile.ko.tab") or die("Cannot create file: $outputfile.ko.tab\n");
open(OUTss, ">$outputfile.subsystems.tab") or die("Cannot create file: $outputfile.subsystems.tab\n");
open(OUTcog, ">$outputfile.cog.tab") or die("Cannot create file: $outputfile.cog.tab\n");
open(OUTec, ">$outputfile.ec.tab") or die("Cannot create file: $outputfile.ec.tab\n");
open(OUTgo, ">$outputfile.go.tab") or die("Cannot create file: $outputfile.go.tab\n");

while ( my $line = <INout> ) {
	chomp $line;
	my @splitline = split(/\t/,$line);
	if ($splitline[-1] eq "KO"){                                                                   #Extract KO numbers
		if (exists($ko{$splitline[-2]})){
			$ko{$splitline[-2]}++;
		}
		else{
			$ko{$splitline[-2]} = 1;
			$koh{$splitline[-2]} = $splitline[-3];                                                 #KO name
		}				
		if (!exists($ecfound{$splitline[1]})){                                                     #to make sure that only one EC entry is taken when looking through the file. Uses KO as the main source.
			if ($splitline[-3] =~ m/\[EC:/) { 	                                                   #Extract EC number
				my @splitline1 = split(/EC:/,$splitline[-3]);
				my @splitline2 = split(/\]/,$splitline1[1]);
				$ecfound{$splitline[1]} = 1;                                                               
				if (exists($ec{$splitline2[0]})){
					$ec{$splitline2[0]}++;
				}
				else{
					$ec{$splitline2[0]} = 1;
					$ech{$splitline2[0]} = $splitline2[0];			                              #EC header not correct!		
				}
			}
		}
	}	
	if ($splitline[-1] eq "Subsystems"){                                                           #Extract subsystem entries
		if (exists($subsystems{$splitline[-2]})){
			$subsystems{$splitline[-2]}++;
		}
		else{
			$subsystems{$splitline[-2]} = 1;
			$subsystemsh{$splitline[-2]} = $splitline[-3]; 
		}				
		if (!exists($ecfound{$splitline[1]})){                                                     #to make sure that only one EC entry is taken when looking through the file. Uses KO as the main source.
			if ($splitline[-3] =~ m/\(EC /) { 	                                                   #Extract EC number
				my @splitline1 = split(/\(EC /,$splitline[-3]);
				my @splitline2 = split(/\)/,$splitline1[1]);
				$ecfound{$splitline[1]} = 1;                                                               
				if (exists($ec{$splitline2[0]})){
					$ec{$splitline2[0]}++;
				}
				else{
					$ec{$splitline2[0]} = 1;
					$ech{$splitline2[0]} = $splitline2[0]; 
				}
			}
		}
	}	
	if ($splitline[-1] eq "COG"){                                                                  #Extract cog entries
		if (exists($cog{$splitline[-2]})){
			$cog{$splitline[-2]}++;
		}
		else{
			$cog{$splitline[-2]} = 1;
			$cogh{$splitline[-2]} = $splitline[-3]; 
		}
	}	
	if ($splitline[-1] eq "GO"){                                                                   #Extract go entries
		if (exists($go{$splitline[-2]})){
			$go{$splitline[-2]}++;
		}
		else{
			$go{$splitline[-2]} = 1;
			$goh{$splitline[-2]} = $splitline[-3]; 
		}
	}		
	
	
	
}

foreach my $konr (sort keys %ko){
	print OUTko "$konr\t$ko{$konr}\t$koh{$konr}\n";
}
foreach my $ecnr (sort keys %ec){
	print OUTec "EC$ecnr\t$ec{$ecnr}\t$ech{$ecnr}\n";
}
foreach my $ssnr (sort keys %subsystems){
	print OUTss "$ssnr\t$subsystems{$ssnr}\t$subsystemsh{$ssnr}\n";
}
foreach my $cognr (sort keys %cog){
	print OUTcog "$cognr\t$cog{$cognr}\t$cogh{$cognr}\n";
}
foreach my $gonr (sort keys %go){
	print OUTgo "$gonr\t$go{$gonr}\t$goh{$gonr}\n";
}

close INout;
close OUTko;
close OUTec;
close OUTss;
close OUTcog;
close OUTgo;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inannotation|a:s", "incluster|c:s", "outputfile|o:s");
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
 [-incluster -c]      Input mg.rast cluster file.
 [-inannotation -a]   Input mg.rast annotation file.
 [-outputfile -o]     Outputfile.
 
=cut