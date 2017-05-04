#!usr/bin/python
################################################################################
# edit the results of the chi square test from tree puzzle to output
# the fasta headers from a file that has the full names of sequences.
#
#
#
#
#
#
################################################################################


import sys
from sys import argv
import re

with open(argv[0], 'r') as failed, open(argv[1],'r') as fullHeaders, open(argv[2],'w') as outfile:
	headers = []
	for line in fullHeaders:
		line.rstrip()
		headers.append(line)
	print headers
	
	for item in failed:
		item.rstrip()
		badAcc = item.split("_")
		print badAcc[0]
		for fasta in headers:
			if fasta.startswith(">"):
				if badAcc[0] in fasta:
					#print(badAcc[0]+"\n"+fasta+"\n")
					outfile.write(fasta)
					print(fasta)
				else:
					pass
			else:
				pass