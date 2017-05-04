#!usr/bin/python
################################################################################
# testCompHetero.py
#
# This program takes a fasta input file and outputs a file where each header has
# been reduced to 10 characters by using the last 10 characters in each header. 
# **This is where I usually specify accession so it should come out with a unique 
# name for each sequence. 
#
# Input must be in fasta format
################################################################################


import sys
from sys import argv
import re
import subprocess
import thread
import threading
import time

# define a function that reads a multi fasta file and outputs the same file
# with all headers trimmed to the leftmost ten characters (uniq accessions).
def tenCharHeaders(filein, fileout):
	with open(filein, 'r') as infile, open(fileout,'w') as outfile:
		for line in infile:
			if line.startswith(">"):
				line.rstrip()
				id = line[-11:]
				#print(id+"\n")
				id = re.sub("\.","_", id)
				#print(id+"\n")
				outfile.write(">"+id+"\n")
			else:
				outfile.write(line)
	infile.close()
	outfile.close()

# Run the function, use threading to wait for it to finish before proceeding
trimming = threading.Thread(target=tenCharHeaders, args=(argv[0], argv[1]))
trimming.start()

while trimming.isAlive():
	time.sleep(0.01)


# Next run the program Tree-Puzzle from within the script, also waiting for completion
# the program is called with "puzzle" command, also specify aln with 10 char headers.
process2 = subprocess.Popen("puzzle "+argv[1], shell=True, stdout=subprocess.PIPE)
process2.wait()
print process.returncode


