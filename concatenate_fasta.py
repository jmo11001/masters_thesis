#!usr/bin/python


# This script concatenates multiple fasta formatted files into a single file, 
# it also changes headers to reflect the major group of origin.

import glob
import re

with open ('archaeal_catalytic_ATPase.fst', 'w') as outfile:
	seqFiles = glob.glob('*.fst')
	#print seqFiles
	for file in seqFiles:
		print ("working on:	"+file+"\n")
		with open (file, 'r') as infile:
			organismID = file.split(".")
			ID = str(organismID[0])
			#print organismID[0]
			for line in infile.readlines():
				#print line
				line = line.rstrip()
				if (line.startswith(">")):
					#print line
					accession = re.search('lcl(.+?)\s', line).group(1)
					accession = re.sub("\|", "", accession)
					#print accession
					outfile.write(">"+ID+"-"+accession+"\n")
					#print (">"+ID+"-"+accession+"\n")
				else:
					outfile.write(line+"\n")
					#print(line+"\n")
		