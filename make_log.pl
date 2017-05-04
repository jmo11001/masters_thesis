#!usr/bin/perl
################################################################################
#get_taxonomy.pl
#
# adapted and expanded:
# for the original code written by Tim Harlow, see:
# <http://giardia.mcb.uconn.edu/~tim/projects/gi2taxonomy101/>
#
# see also for description, renaming section of chapter 1 methods
#
# essentially the same code as get_taxonomy_gi.pl and cluster_get_taxonomy_gi.pl
# except that this code is used strictly to produce a log file. This was an 
# afterthought after running the actual renaming code, and that is why its included
# as a separate script.
################################################################################



use LWP::Simple;
use XML::Simple;


open (LOG, ">rename_index.txt");

print LOG ("Alignment" . "\t" . "New Header" . "\t" . "GI" . "\t" . "Acession" . "\t" . "Group Name" . "\t" . "Taxid" . "\t" . "Lineage" . "\t" . "Original Header" . "\n");

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
	
	@identifiers = ();
	@old_headers = ();
	@missing_accessions = ();
	@no_taxid = ();
	@no_lineage_info = ();
	@group_hash_mismatch = ();
	@file_headers = ();
	
	open (IN, "<$file");

	while (defined($line = <IN>)){
		if ($line =~ m/>/){
			chomp $line;
			push (@old_headers, $line);
			my @header = (split '\/', $line);
			$gi_number = $header[0];
			$gi_number =~ s/>//;
			push (@identifiers, $gi_number);
			
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
				push (@no_taxid, "Missing");
				#print ("missing taxid for:" . "\t" . $gi_number . "\n");
			}
			else{
				push (@no_taxid, $taxid);
			}
			
			$accession = '';
			my @parts = split /TSeq_accver/, $xml;
			$accession = $parts[1];
			$accession =~ s/>//;
			$accession =~ s/<//;
			$accession =~ s{/}{};
			#print "$accession\n";
			if ($accession eq '') {
				push (@missing_accessions, "Missing");
				#print ("missing accession for:" . "\t" . $gi_number . "\n");
			}
			else{
				push (@missing_accessions, $accession);
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
				push (@no_lineage_info, "Missing");
				#print ("missing lineage info for:" . "\t" . $gi_number . "\n");
			}
			else{
				push (@no_lineage_info, $lineage);
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
			$temp_hold = '';
			foreach $key ( keys %groups ){
				if ($lineage =~ m/$key/){
					$b = $groups{$key};
					$temp_hold = $key;
				}
			}
			
			if ($b eq '') {
				$missing_group = ($gi_number . "\t" . $accession . "\t" . $lineage);
				push (@group_hash_mismatch, "No Match");
				#print ("missing group name for:" . "\t" . $gi_number . "\t" . $lineage . "\n");
			}
			else{
				push (@group_hash_mismatch, $temp_hold);
			}
			
			$new_header = (">" . $a . "_" . $b . "_" . $accession);
			push (@file_headers, $new_header);
			
		}

	}

	for ($i = 0; $i <= @file_headers; $i++){
		
		print LOG ($file . "\t" . $file_headers[$i] . "\t" . $identifiers[$i] . "\t" . $missing_accessions[$i] . "\t" . $group_hash_mismatch[$i] . "\t" . $no_taxid[$i] . "\t" . $no_lineage_info[$i] . "\t" . $old_headers[$i] . "\n");
	
	}
	
	close IN;

}

close LOG