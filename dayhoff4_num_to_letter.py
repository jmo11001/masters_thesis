#!usr/bin/python
################################################################################
#
################################################################################

import re
import sys
from sys import argv


with open('dayhoff_4_class.fst', 'r') as infile, open('dayhoff_4class_alpha.fst', 'w') as outfile:
	for line in infile:
		if line.startswith(">"):
			outfile.write(line)
		else:
			recode = re.sub(r'0','A',line  )
			recode = re.sub(r'1','D',recode)
			recode = re.sub(r'2','R',recode)
			recode = re.sub(r'3','M',recode)
			outfile.write(recode)