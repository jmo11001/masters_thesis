#!usr/bin/perl
################################################################################
#get_taxonomy.pl
#
# adapted and expanded:
# for the original code written by Tim Harlow, see:
# <http://giardia.mcb.uconn.edu/~tim/projects/gi2taxonomy101/>
#
# see also for description, renaming section of chapter 1 methods
################################################################################


### Get the taxonomy ID for a given nucleotide GI number
#use LWP::Simple;
#use XML::Simple;
#
#$gi = AHY46265.1;
#
#$eutil = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?";
#$query = "dbfrom=nuccore&db=taxonomy&id=$gi";
#$url = $eutil.$query;
#
#$xml = get( $url );
#$tree = XMLin( $xml );
#
#$taxid = $tree->{"LinkSet"}->{"LinkSetDb"}->{"Link"}->{"Id"};
#print "$taxid\n";
#
###


### Get the taxonomy ID for a given protein GI number

use LWP::Simple;
use XML::Simple;

# here a specific accession number is provided as an example,
# but this code can be modified to provide accession numbers in batch
$accession = "YP_264815.1";

#In Tim's example, the elinks function was being invoked. I couldn't 
#get this method to return a usable xml output. However, by switching
#to efetch I was able to get an output I could work with
$eutil = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?";
$query = "db=protein&id=$accession&rettype=fasta&retmode=xml";
$url = $eutil.$query;

$xml = get( $url );
#$tree = XMLin( $xml );

#$taxid = $tree->{"LinkSet"}->{"LinkSetDb"}->{"Link"}->{"Id"};
#print "$taxid\n";

#print "$xml\n";
#print "$tree\n";


#Tim's step of hashing the xml variable using XMLin didn't seem to 
#be pulling out the taxonid, So I got crafty and used regex to retrieve
#this info in a much less elegant manner.
my @parts = split /TSeq_taxid/, $xml;
$taxid = $parts[1];
$taxid =~ s/>//;
$taxid =~ s/<//;
$taxid =~ s{/}{};
print "$taxid\n";


### Get details of the taxonomy ID

$eutil = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?";
$query = "db=taxonomy&id=$taxid";
$url = $eutil.$query;

$xml = get( $url );
$tree = XMLin( $xml );

$lineage = $tree->{"Taxon"}->{"Lineage"};
#my @parts = split /Lineage/, $xml;
#$lineage = $parts[1];
#$lineage =~ s/>//;
#$lineage =~ s/<//;
#$lineage =~ s{/}{};
print "$lineage\n\n";

#foreach $taxon (@{$tree->{"Taxon"}->{"LineageEx"}->{"Taxon"}}) {
#    print $taxon->{"Rank"};
#    print "\t";
#    print $taxon->{"ScientificName"};
#    print "\n";
#}



