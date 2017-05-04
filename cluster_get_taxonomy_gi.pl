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

open (LOG, ">>rename_index_12_5_16.txt");
print LOG ("Alignment" . "\t" . "New Header" . "\t" . "GI" . "\t" . "Accession" . "\t" . "Group Name" . "\t" . "Taxid" . "\t" . "Lineage" . "\t" . "Original Header" . "\n");

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
		Tenericutes => 'TE',
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
		Caldisericales => 'CS',
		Chrysiogenales => 'CR',
		Dictyoglomales => 'DG',
		Elusimicrobia => 'EM',
		Cloacimonetes => 'CM',
		Fibrobacterales => 'FB',
		Gemmatimonadales => 'GM',
		Nitrospirales => 'NP',
		Acidithiobacillales => 'AD',
		Verrucomicrobia => 'VM',
		Tissierellales => 'TS',
		Erysipelotrichales => 'EY',
		Thermobaculum => 'TB',
		Thermodesulfobacteriales => 'TD',
		Nanoarchaeales => 'NA',
		Methanopyrales => 'MP',
		Korarchaeota => 'KA',
		Acidilobales => 'AB',
		Fervidicoccales => 'FV',
		Cenarchaeales => 'CA',
		Nitrosopumilales => 'NS',
	);

@alns = glob "*.fst";

foreach $file (@alns){
	print ("renaming sequences in alignment: $file" . "\n");
	@no_ext = split /\./, $file;
	$outname = ("$no_ext[0]". "_named.fasta");

	@identifiers = ();
	@old_headers = ();
	@missing_accessions = ();
	@no_taxid = ();
	@no_lineage_info = ();
	@group_hash_mismatch = ();
	@file_headers = ();
	
	open (IN, "<$file");
	open (OUT, ">$outname");

	while (defined($line = <IN>)){
		if ($line =~ m/>/){
			chomp $line;
			push (@old_headers, $line);
			#print OUT "$line\n";
			my @header = (split '\/', $line);
			$gi_number = $header[0];
			$gi_number =~ s/>//;
			#print "$gi_number\n";
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
			
			$new_header = '';
			$new_header = (">" . $a . "_" . $b . "_" . $accession);
			if ($new_header ne '>__'){
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);
			}
			elsif ($gi_number eq '152995358'){
				$new_header = ">Bact_GP_152995358";
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);
			}
			elsif ($gi_number eq '330465868'){
				$new_header = ">Bact_AT_330465868";
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);
			}			
			elsif ($gi_number eq '330812086'){
				$new_header = ">Bact_GP_330812086";
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);
			}
			elsif ($gi_number eq '374308541'){
				$new_header = ">Bact_AT_374308541";
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);
			}
			else{
				$new_header = (">ARCH_HA_" . $gi_number);
				print OUT ($new_header . "\n");
				push (@file_headers, $new_header);		
			}					
		}
		
		else{
			chomp $line;
			print OUT "$line\n";
		}
		
	}

	for ($i = 0; $i <= @old_headers; $i++){
		
		print LOG ($file . "\t" . $file_headers[$i] . "\t" . $identifiers[$i] . "\t" . $missing_accessions[$i] . "\t" . $group_hash_mismatch[$i] . "\t" . $no_taxid[$i] . "\t" . $no_lineage_info[$i] . "\t" . $old_headers[$i] . "\n");
	
	}
	
	close IN;
	close OUT;

}

close LOG;