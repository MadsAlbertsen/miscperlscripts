#!/usr/bin/env perl
###############################################################################
#
#    split.amphora.alignments.bins.pl
#
#	 Splits amphora protein alignments into different bins and makes easy
#    readable stats and overview files.
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

#my $inputfile;
my $inbins;
my $nobins;

#$inputfile = &overrideDefault("inputfile.fasta",'inputfile');
$inbins = &overrideDefault("inbins.tab",'inbins');
$nobins = &overrideDefault("0",'nobins');


my $header;
my $seq;
my $prevheader;
my %bins;
my %contigs;

######################################################################
# CODE HERE
######################################################################


open(STATS, ">stats.txt") or die("Cannot read file: stats.txt\n");
print STATS "protein\tbin\t#sequences\tavg.length\torf.length\torf.id\n";

if ($nobins == 0){
	open(INbins, $inbins) or die("Cannot read file: $inbins\n");
	while (my $line = <INbins> ) {                                                                     #Read in the bins
		chomp $line; 
		my @splitline = split(/\t/, $line);
		$contigs{$splitline[0]} = $splitline[1];
		if (!exists($bins{$splitline[1]})){
			$bins{$splitline[1]}++;
		}
		else{
			$bins{$splitline[1]} = 1;
		}
	}
	close INbins;
	}
	else{
			$bins{0} = 1;
	}

#Read in the different alignments one by one

opendir(DIR, '.') or die "Cannot open dir $!";
my $filename;

foreach my $bin (sort keys %bins) {
	my $outputfile = "bin.".$bin.".fasta";
	open(OUT, ">$outputfile") or die("Cannot create file: $outputfile\n");						   #>> = append to file or create it
	close OUT;
}

while ( $filename = readdir(DIR)){
	if ($filename =~/.*.aln/){		
		my $count = 0;
		my %sequences;
		open(INaln, $filename) or die("Cannot read file: $filename\n");
		while (my $line = <INaln>)  {	                                                                   
			chomp $line;
			if ($line =~ m/>/) {
				$header = $line;				
				if ($count > 0){
					$sequences{$prevheader} = $seq;
					if($nobins == 1){															   #If nobins is needed we make a hack to just dummy bin all orfs as bin 0
						my @splitline = split(/_/,$prevheader);
						$contigs{$splitline[0]} = 0;
					}
				}
				$count++;
				$seq = "";
				$prevheader = $header;		
			}
			else{
				$seq = $seq.$line;
			}
		}
		$sequences{$prevheader} = $seq;                                                                    #To catch the last sequence..	
		if($nobins == 1){											                      		   #If nobins is needed we make a hack to just dummy bin all orfs as bin 0
			my @splitline = split(/_/,$prevheader);
		$contigs{$splitline[0]} = 0;
					}
		#Write the outputfiles one by one
		foreach my $bin (sort keys %bins) {
			my $outputfile = "bin.".$bin.".fasta";
			my $outputfile2 = "bin.".$bin.".seqs.faa";
			open(OUT, ">>$outputfile") or die("Cannot create file: $outputfile\n");				   #>> = append to file or create it
			open(OUTfasta, ">>$outputfile2") or die("Cannot create file: $outputfile2\n");				   #>> = append to file or create it
			my $count1 = 0;
			my $count2 = 0;
			my $length = 0;
			my $notlength = 0;
			my $catlength = '';
			my $catorfid = '';
			my $notcatlength = '';
			my $notorfid = '';
			my $avglength = 0;			
			foreach my $sequence (keys %sequences){
				my @splitline = split(/_/,$sequence);
				if (exists($contigs{$splitline[0]})){
					if ($bin eq $contigs{$splitline[0]}){
						$filename =~ s/.aln//g;
						print OUT "$filename\t$sequences{$sequence}\t $sequence\n";		           #Print the alignment in readable format
						print OUTfasta "$sequence",'_',"$filename\n";	
						$sequences{$sequence} =~ s/-//g;                                           #To get the real length without gaps and print the pure fasta file
						$sequences{$sequence} = uc($sequences{$sequence});
						print OUTfasta "$sequences{$sequence}\n";
						$count1++;					 	 				   
						$length = $length + length($sequences{$sequence});
						$catlength = $catlength.length($sequences{$sequence}).";";
						$catorfid= $catorfid.$sequence.";";
					}		
				}
				else{
					$sequences{$sequence} =~ s/-//g;
					$notlength = $notlength + length($sequences{$sequence});
					$notcatlength = $notcatlength.length($sequences{$sequence}).";";						
					$notorfid = $notorfid.$sequence.";";
					delete $sequences{$sequence};
					$count2++;

				}
				
			}
			$filename =~ s/.aln//g;
			if ($count1 > 0){
				$avglength = $length/$count1;
				print STATS "$filename\t$bin\t$count1\t",sprintf("%.1f",$avglength),"\t$catlength\t$catorfid\n";
			}			
			if ($count2 > 0){
				$avglength = $notlength/$count2;
				print STATS "$filename\tnot.in.bin\t$count2\t",sprintf("%.1f",$avglength),"\t$notcatlength\t$notorfid\n";
			}			
			close OUT;
			close OUTfasta;
		}
	close INaln;
	}
}

close STATS;

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inbins|b:s","nobins|n+");
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

    split.amphora.alignments.bin.pl

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
 [-inbins -b]         Tab seperated binfile (name tab bin)
 [-nobins -n]         Flag to indicate no bins.
 
=cut