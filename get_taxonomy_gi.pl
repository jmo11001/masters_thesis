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



use LWP::Simple;
use XML::Simple;

#open (INDEX, "<Nelson-Sathi_et_al_2014_index2header.txt");
open (LOG, ">logfile_name_conv.txt");

%groups = (
        Thermoproteales => 'TP',
        Desulfurococcales => 'DE',
        Sulfolobales => 'SU',
		Thermococci => 'TC',
		Methanobacteriales => 'MB',
		Methanococcales => 'MO',
		Thermoplasmatales => 'TL',
		Archaeoglobales => 'AR',
		Methanomicrobiales => 'MM',
		Methanocellales => 'MC',
		Methanosarcinales => 'MS',
		Halobacteria => 'HA',
		Thermotogae => 'TT',
		Aquificae => 'AQ',
		Fusobacteria => 'FU',
		Deinococci => 'DT',
		Chlorobi => 'CB',
		Chloroflexi => 'CF',
		Cyanobacteria => 'CY',
		Clostridia => 'CL',
		Negativicutes => 'NE',
		Tenricutes => 'TE',
		Bacilli => 'BI',
		Actinobacteria => 'AT',
		Alphaproteobacteria => 'AP',
		Betaproteobacteria => 'BP',
		Gammaproteobacteria => 'GP',
		Deltaproteobacteria => 'DP',
		Epsilonproteobacteria => 'EP',
		Spirochaetes => 'SP',
		Planctomycetes => 'PL',
		Chlamydiae => 'CH',
		Acidobacteria => 'AC',
		Bacteriodetes => 'BA',
		Lentisphaerae => 'LS',
		Synergistetes => 'SY',
		Deferribacteres => 'DF',
		DHVE2 => 'DH',
	);

@alns = glob "*.fst";

foreach $file (@alns){
	print ("renaming sequences in alignment: $file" . "\n");
	@no_ext = split /\./, $file;
	$outname = ("$no_ext[0]". "_named.fasta");

	@missing_accessions = ();
	@no_taxid = ();
	@no_lineage_info = ();
	@group_hash_mismatch = ();
	
	open (IN, "<$file");
	open (OUT, ">$outname");

	while (defined($line = <IN>)){
		if ($line =~ m/>/){
			chomp $line;
			#print OUT "$line\n";
			my @header = (split '\/', $line);
			$gi_number = $header[0];
			$gi_number =~ s/>//;
			#print "$gi_number\n";
			
			$eutil = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?";
			$query = "db=protein&id=$gi_number&rettype=fasta&retmode=xml";
			$url = $eutil.$query;
			
			sleep(0.5);
			
			#print "$url\n";
			$xml = get($url);
			#print "$xml\n";
			
			$taxid = '';
			$xml =~ /taxid>(\d+)/;
			$taxid = $1;
			#print "$taxid\n";
			if ($taxid eq '') {
				push (@no_taxid, $gi_number);
				#print ("missing taxid for:" . "\t" . $gi_number . "\n");
			}
			
			$accession = '';
			my @parts = split /TSeq_accver/, $xml;
			$accession = $parts[1];
			$accession =~ s/>//;
			$accession =~ s/<//;
			$accession =~ s{/}{};
			#print "$accession\n";
			if ($accession eq '') {
				push (@missing_accessions, $gi_number);
				#print ("missing accession for:" . "\t" . $gi_number . "\n");
			}
			
			
			$eutil = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?";
			$query = "db=taxonomy&id=$taxid";
			$url = $eutil.$query;
			
			sleep(0.5);
			
			$xml = get( $url );
			$tree = XMLin( $xml );
			
			$lineage = '';
			$lineage = $tree->{"Taxon"}->{"Lineage"};
			#print "$lineage\n";
			if ($lineage eq '') {
				push (@no_lineage_info, $gi_number);
				#print ("missing lineage info for:" . "\t" . $gi_number . "\n");
			}
			
			$a = '';
			@group = split (/\;/ , $lineage);
			if ($group[1] =~ m/Bacteria/) {
				$a = "Bact";
			}
			if ($group[1] =~ m/Archaea/) {
				$a = "Arch";
			}
			
			$b = '';
			foreach $key ( keys %groups ){
				if ($lineage =~ m/$key/){
					$b = $groups{$key};
				}
			}
			
			if ($b eq '') {
				$missing_group = ($gi_number . "\t" . $accession . "\t" . $lineage);
				push (@group_hash_mismatch, $missing_group);
				#print ("missing group name for:" . "\t" . $gi_number . "\t" . $lineage . "\n");
			}
			
			$new_header = (">" . $a . "_" . $b . "_" . $accession . "\n");
			print OUT $new_header;
			
		}
		else{
			chomp $line;
			print OUT "$line\n";
		}
	}

	print LOG ($file . ": missing data\n");
	
	print LOG ("\t" .  "Acession numbers not found for the following GI's:\n");
	foreach $thing (@missing_accessions) {
		print LOG ("\t\t" . "$thing" . "\n");
	}
	
	print LOG ("\t" .  "Taxonomy IDs not found for the following GI's:\n");
	foreach $thing (@no_taxid) {
		print LOG ("\t\t" . "$thing" . "\n");
	}
	
	print LOG ("\t" .  "Lineage info not found for the following GI's:\n");
	foreach $thing (@no_lineage_info) {
		print LOG ("\t\t" . "$thing" . "\n");
	}

	print LOG ("\t" .  "Group abbreviation not found for the following lineages:\n");
	foreach $thing (@group_hash_mismatch) {
		print LOG ("\t\t" . "$thing" . "\n");
	}
	
	
	close IN;
	close OUT;

}