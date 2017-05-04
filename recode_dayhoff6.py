!usr/bin/python
################################################################################
# This is a script used to perform a translation on an amino acid multiple
# sequence alignment. It recodes the dataset into six character classes 
# based on R group similar biochemical characteristics, and which commonly 
# replace one another in substitutions. This method can be useful in
# downstream phylogenetic reconstruction. It may help resolve the 
# placement of long branches in the tree, by only considering substitutions
# have potential to cause a significant difference in protein structure. 
# For example, a substitution of one small hydrophobic residue to another
# small hydrophobic residue in a protein likely doesn't affect the function, 
# and these two residues would be coded by the same class.
#
# For more detail, see Hrdy et al. 2004, Trichomonas hydrogenosomes contain 
# the NADH dehydrogenase module of mitochondrial complex I. Nature, 432: 618-622
#
# Input sequence file must be in Fasta format
#
# Recoding is done to characters 0-5 for the 6 biochemical classes of amino acids.
# The classes are numbered from 0 rather than 1 because RAxML can accept multi 
# state character data, but the dataset must start from 0 (see RAxML manual,
# -m option)
#
################################################################################



import re

with open('atpase.mus.fst','r') as protAlignment, open('dayhoff_4_class.fst','w') as dayhoffRecoded:
	
	### Set your Dayhoff Recoding characters for the 6 groups
	
	group0 = "0"
	group1 = "1"
	group2 = "2"
	group3 = "3"
	group4 = "4"
	group5 = "5"
	
	
	### This for loop reads through every line of the input file, does
	### nothing if the line starts with a fasta character, and 
	
	for line in protAlignment:
		if line.startswith(">"):
			dayhoffRecoded.write(line)
		else:
			recode = re.sub(r'A|S|T|G|P',      group0,line  )
			recode = re.sub(r'D|N|E|Q',        group1,recode)
			recode = re.sub(r'R|K|H',          group2,recode)
			recode = re.sub(r'M|V|I|L',        group3,recode)
			recode = re.sub(r'F|Y|W',          group4,recode)
			recode = re.sub(r'C',              group5,recode)
			dayhoffRecoded.write(recode)