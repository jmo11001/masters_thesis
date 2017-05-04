#!usr/bin/python
################################################################################
# ten_character_headers.py
#
# This program takes a fasta input file and outputs a file where each header has
# been reduced to 10 characters by using the last 10 characters in each header. 
# **This is where my sequences have accession so it should come out with a unique 
# name for each sequence. 
#
# Input must be in fasta format
#
# usage:
# $ python ten_character_headers.py input_full.fst ten_char_headers.fst full_headers.txt
#   	   this script				raw input	   output				text file needed later 
################################################################################


import sys
from sys import argv

import re



with open(argv[1], 'r') as infile, open(argv[2],'w') as outfile, open (argv[3], 'w') as fullheaders:
	for line in infile:
		if line.startswith(">"):
			fullheaders.write(line)
			line.rstrip()
			id = line[-11:]
			#print(id+"\n")
			id = re.sub("\.","_", id)
			#print(id+"\n")
			outfile.write(">"+id)
		else:
			outfile.write(line)






