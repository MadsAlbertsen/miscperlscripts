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


my $dir;

$dir = &overrideDefault(".",'dir');
 
my $filename;
my %categories;
my $header;
my %catheader;


######################################################################
# CODE HERE
######################################################################

open(OUTcog, ">all.cog.txt") or die("Cannot create file: all.cog.txt\n");

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
$header = "GeneFamily";
while ( $filename = readdir(DIR)){                                                                 #Read all cog files and concatetate them
	if ($filename =~/.cog.tab/){	
		$header = $header."\t".$filename;
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$categories{$splitline[0]} = $splitline[0];
			$catheader{$splitline[0]} = $splitline[2];
		}
		close IN;		
	}
}
closedir DIR;

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 
	if ($filename =~/.cog.tab/){	
		my %cog = ();		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$cog{$splitline[0]} = $splitline[1];
			$catheader{$splitline[0]} = $splitline[2];
		}		
		close IN;		
		foreach my $key (keys %categories){
			if (exists($cog{$key})){
				$categories{$key} = "$categories{$key}\t$cog{$key}";
			}
			else{
				$categories{$key} = "$categories{$key}\t0";
			}
		}
	}
}
print OUTcog "$header\n";
foreach my $key (keys %categories){
	print OUTcog "$categories{$key}\t$catheader{$key}\n";
}
close OUTcog;
closedir DIR;

open(OUTec, ">all.ec.txt") or die("Cannot create file: all.ec.txt\n");
$header = "GeneFamily";
%categories = ();
opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 #Read all ec files and concatetate them
	if ($filename =~/.ec.tab/){	
		$header = $header."\t".$filename;
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$categories{$splitline[0]} = $splitline[0];
			$catheader{$splitline[0]} = $splitline[2];
		}
		close IN;		
	}
}
closedir DIR;

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 
	if ($filename =~/.ec.tab/){	
		my %ec = ();		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$ec{$splitline[0]} = $splitline[1];
		}		
		close IN;		
		foreach my $key (keys %categories){
			if (exists($ec{$key})){
				$categories{$key} = "$categories{$key}\t$ec{$key}";
			}
			else{
				$categories{$key} = "$categories{$key}\t0";
			}
		}
	}
}
print OUTec "$header\n";
foreach my $key (keys %categories){
	print OUTec "$categories{$key}\t$catheader{$key}\n";
}
close OUTec;
closedir DIR;

open(OUTgo, ">all.go.txt") or die("Cannot create file: all.go.txt\n");
$header = "GeneFamily";
%categories = ();
opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 #Read all GO files and concatetate them
	if ($filename =~/.go.tab/){	
		$header = $header."\t".$filename;
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$categories{$splitline[0]} = $splitline[0];
			$catheader{$splitline[0]} = $splitline[2];
		}
		close IN;		
	}
}
closedir DIR;

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 
	if ($filename =~/.go.tab/){	
		my %go = ();		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$go{$splitline[0]} = $splitline[1];
		}		
		close IN;		
		foreach my $key (keys %categories){
			if (exists($go{$key})){
				$categories{$key} = "$categories{$key}\t$go{$key}";
			}
			else{
				$categories{$key} = "$categories{$key}\t0";
			}
		}
	}
}
print OUTgo "$header\n";
foreach my $key (keys %categories){
	print OUTgo "$categories{$key}\t$catheader{$key}\n";
}
close OUTgo;
closedir DIR;

open(OUTko, ">all.ko.txt") or die("Cannot create file: all.ko.txt\n");
$header = "GeneFamily";
%categories = ();
opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 #Read all KO files and concatetate them
	if ($filename =~/.ko.tab/){	
		$header = $header."\t".$filename;
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$categories{$splitline[0]} = $splitline[0];
			$catheader{$splitline[0]} = $splitline[2];
		}
		close IN;		
	}
}
closedir DIR;

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 
	if ($filename =~/.ko.tab/){	
		my %ko = ();		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$ko{$splitline[0]} = $splitline[1];
		}		
		close IN;		
		foreach my $key (keys %categories){
			if (exists($ko{$key})){
				$categories{$key} = "$categories{$key}\t$ko{$key}";
			}
			else{
				$categories{$key} = "$categories{$key}\t0";
			}
		}
	}
}
print OUTko "$header\n";
foreach my $key (keys %categories){
	print OUTko "$categories{$key}\t$catheader{$key}\n";
}
close OUTko;
closedir DIR;

open(OUTss, ">all.subsystems.txt") or die("Cannot create file: all.subsystems.txt\n");
$header = "GeneFamily";
%categories = ();
opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 #Read all KO files and concatetate them
	if ($filename =~/.subsystems.tab/){			
		$header = $header."\t".$filename;		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$categories{$splitline[0]} = $splitline[0];
			$catheader{$splitline[0]} = $splitline[2];
		}
		close IN;		
	}
}
closedir DIR;

opendir(DIR, $dir) or die "Cannot open dir: $dir!";
while ( $filename = readdir(DIR)){                                                                 
	if ($filename =~/.subsystems.tab/){	
		my %ss = ();		
		open(IN, $filename) or die("Cannot read file: $filename\n");	
		while (my $line = <IN>)  {	                                                                   
			chomp $line;
			my @splitline = split(/\t/,$line);
			$ss{$splitline[0]} = $splitline[1];
		}		
		close IN;		
		foreach my $key (keys %categories){
			if (exists($ss{$key})){
				$categories{$key} = "$categories{$key}\t$ss{$key}";
			}
			else{
				$categories{$key} = "$categories{$key}\t0";
			}
		}
	}
}
print OUTss "$header\n";
foreach my $key (keys %categories){
	print OUTss "$categories{$key}\t$catheader{$key}\n";
}
close OUTss;
closedir DIR;


######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "dir|d:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    #exec("pod2usage $0") if (0 == (keys (%options) ));

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
 [-dir -d]            Location of files (default: .)
 
=cut