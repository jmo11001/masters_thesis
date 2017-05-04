#!usr/bin/python
################################################################################
# This script opens a record file downloaded from the NCBI genome browser.
# It ultimately relies on the use of the python package "urllib" to 
# download genome information using the ftp address of each genome, 
# which is specified in columns 19 and 20 of each row. 
#
# This script was written to specifically download protein coding sequences
# for each genome, or ".faa" files, and only to download nucleotide coding 
# data if protein couldn't be found at either of the two ftp addresses.
# Additionally, this script also looks in the 5th column of the excel file,
# (filepath[5]) where I had manually inserted a unique name based on group 
# and number for each genome (otherwise downloads can be named according to 
# ftp address
#
# NCBI genome browser: <https://www.ncbi.nlm.nih.gov/genome/browse/>
################################################################################


import re
import sys
import os 
import os.path
import gzip
import subprocess
import urllib

links = []
with open('NCBI_genome_browser_all_archaea_abbrv.txt','r') as infile, open('group.sp_abbrv_dictionary.txt','w') as dict:
	next(infile)
	for line in infile:
		field = line.split("\t")
		#get url and remote filename
		genbankFTP = field[19]
		remNewLine = genbankFTP.rstrip()
		filePath = remNewLine.split("/")
		ftpFile = (filePath[5]+"_protein.faa.gz")
		faaFTP = (remNewLine+"/"+ftpFile)
		#for dictionary
		group = re.sub("\s", "-", field[5])
		subgroup = re.sub("\s", "-", field[6])
		species = re.sub("\s", "-", field[0])
		fullName = (group+"_"+subgroup+"_"+species+"_"+ftpFile)
		#get abbreviation for name
		abbrv = field[7]
		localName = (abbrv+"-"+ftpFile)
		try:
			urllib.urlretrieve(faaFTP, filename=localName)
			print ("retrieved 1st attempt: "+localName)
			dict.write(fullName+"\t"+localName+"\n")
		except:
			try:
				#get url and remote filename
				attemptTwo = field[18]
				fileAltPath = attemptTwo.split("/")
				ftpAltFile = (fileAltPath[5]+"_protein.faa.gz")
				faaAltFTP = (attemptTwo+"/"+ftpAltFile)
				#for dictionary
				groupAlt = re.sub("\s", "-", field[5])
				subgroupAlt = re.sub("\s", "-", field[6])
				speciesALT = re.sub("\s", "-", field[0])
				fullNameAlt = (groupAlt+"_"+subgroupAlt+"_"+speciesALT+"_"+ftpAltFile)
				#get abbreviation for name
				abbrv = field[7]
				localNameAlt = (abbrv+"-"+ftpAltFile)
				#retrieval
				urllib.urlretrieve(faaAltFTP, filename=localNameAlt)
				print ("retrieved 2nd attempt: "+localNameAlt)
				dict.write(fullNameAlt+"\t"+localNameAlt+"\n")
			except:
				try:
					#get url and remote filename
					fnaFile = (filePath[5]+"_genomic.fna.gz")
					fnaFTP = (remNewLine+"/"+fnaFile)
					#for dictionary
					groupFNA = re.sub("\s", "-", field[5])
					subgroupFNA = re.sub("\s", "-", field[6])
					speciesFNA = re.sub("\s", "-", field[0])
					fullNameFNA = (groupFNA+"_"+subgroupFNA+"_"+speciesFNA+"_"+fnaFile)
					#get abbreviation
					abbrv = field[7]
					localNameFNA = (abbrv+"-"+ftpAltFile)
					#retrieval
					urllib.urlretrieve(fnaFTP, filename=localNameFNA)
					print ("FNA retrieved: "+localNameFNA)
					dict.write(fullNameFNA+"\t"+localNameFNA+"\n")
				except:
					print ("Failed: "+ftpFile)

		