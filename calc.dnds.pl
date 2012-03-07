#!/usr/bin/env perl
###############################################################################
#
#    calc.dnds.pl
#
#	 Calculates pairwise dn/ds ratios of all input sequences. Note: the sequences
#	 have to be alligned and in fasta format. In addition its assumed they start in
#    frame.
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

#Bioperl modules
use Bio::Seq;
use Bio::AlignIO;
use BIO::Align::DNAStatistics;

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
my $tempheader;
my %header;
my %sequence;
$inputfile = &overrideDefault("inputfile.txt",'inputfile');

######################################################################
# CODE HERE
######################################################################

# use Bio::AlignIO to read in the alignment
my $str = Bio::AlignIO->new('-file' => $inputfile);                                                #To get the length of the sequences. (Assumes that tey are all equal length)
my $aln = $str->next_aln();
my $seqlength = $aln->length/3;  

my $stats = Bio::Align::DNAStatistics->new();                                                      #Create the stats variable.
my $in = Bio::AlignIO->new(-format => 'fasta', -file => $inputfile);                               #Add the input fasta file.
my $alnobj = $in->next_aln;                                                                        #Add objects that need to be aligned. By taking each sequence from the in file one by one.
my ($seq1id,$seq2id) = map { $_->display_id } $alnobj->each_seq;                                   #create the combinations of sequences that need to be compared.
my $results = $stats->calc_all_KaKs_pairs($alnobj);                                                #Calculate all stats.
my %Nd;
my %Sd;

for my $an (@$results){                                                                            #Get the results that are needed for the output
    for (sort keys %$an ){
        next if /Seq/;
		if ($_ eq "N_d"){
			my $tempcomp = $an->{'Seq1'}." vs ".$an->{'Seq2'}; 
			$Nd{$tempcomp} = $an->{$_};
		}
		if ($_ eq "S_d"){
			my $tempcomp = $an->{'Seq1'}." vs ".$an->{'Seq2'}; 
			$Sd{$tempcomp} = $an->{$_};
		}		
    }
}

print "comparison\tAA.length\tdN/dS\t#dN\t#dS\t%AA.sim\n";

foreach my $key (sort keys %Nd){	
	my $tempcalc = $Nd{$key}/$Sd{$key};
	my $tempcalc2 = (1-$Nd{$key}/$seqlength)*100;
	print "$key\t$seqlength\t",sprintf("%.2f",$tempcalc),"\t",sprintf("%.0f",$Nd{$key}),"\t",sprintf("%.0f",$Sd{$key}),"\t",sprintf("%.1f",$tempcalc2),"\n";	
}

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

    calc.dsdn.pl

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
 [-inputfile -i]      Aligned in frame fasta file.  
 
=cut