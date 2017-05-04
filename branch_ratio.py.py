#!usr/bin/python
################################################################################
# also named as: calc_maxgrouplength_to_interdomainbranch_ratio
# which was clearly too long of a name. 
#
# See chapter 1 methods, section Branch Length Analysis
#
#################################################################################


import glob
import Bio
from Bio import Phylo
import re
import dendropy
import Bio.Phylo.BaseTree


files = glob.glob('*.tre')
files = sorted(files, reverse = True)

# iterate through a set of unrooted tree files
for file in files:
	# read in the files as objects of class 'Bio.Phylo.Newick.Tree'
	tree = Phylo.read(file , 'newick')
	# Use the 'get.terminals()' function to get the namess of the 
	# tips on the tree that was just read in, append them to a list
	species_list = []
	for leaf in tree.get_terminals():
		species_list.append(leaf.name)
	
	# here I'm taking advantage of the way I named the sequences.
	# I named each sequence according to "Domain_groupabbreviation"
	# For example, a sequence from a Haloarchaeon: "Arch_HA_"
	# and after this prefix would come a GI number.
	# see: cluster_get_taxonomy_gi.pl
	group_names = []
	for tip in species_list:
		partition =  tip.split("_")
		group = (partition[0]+"_"+partition[1])
		group_names.append(group)
	
	
	### Use the BioPhylo "distance" function to find the values
	unique_groups = list(set(group_names))
	#longest_within_group_dist = []
	longest_length_list = []
	for group in unique_groups:
		group_tips = []
		for species in species_list:
			if group in species:
				group_tips.append(species)
		#print(group+":"+str(group_tips))
		temp_dist = []
		for start in group_tips:
			#tip_path = tree.get_path(tip)
			#print tip_path
			for end in group_tips:
				if start == end:
					pass
				else:
					traversal_dist = tree.distance(start, end)
					#print (group+": "+str(traversal_dist))
					temp_dist.append(traversal_dist)
		if not temp_dist:
			pass
		else:
			group_max_named = (group+": "+str(max(temp_dist)))
			group_maximums_floating = str(max(temp_dist))
			#print group_max
			#longest_within_group_dist.append(group_max_named)
			longest_length_list.append(group_maximums_floating)
			max_dist_within_any_group = max(longest_length_list)

	#print longest_within_group_dist
	#print max_dist_within_any_group

	within_group_length	= float(max_dist_within_any_group)
	
	### Get the length of the branch attaching the Archaea to the Bact	
	arch_list = []
	for species in species_list:
		if "Arch_" in species:
			arch_list.append(species)
	
	bact_list = []
	for species in species_list:
		if "Bact_" in species:
			bact_list.append(species)		
			
	#returns the length of the branch attaching this subtree to the rest of the tree
	arch_to_bact_branch_length = tree.common_ancestor(arch_list)
	#returns the length of the branch attaching this subtree to the rest of the tree
	bact_to_arch_branch_length = tree.common_ancestor(bact_list)
	
	branch_value = ()
	final_ratio = None
	try:		
		obj_props = [property for property in vars(bact_to_arch_branch_length).iteritems()]
		branch_value = obj_props[1]
		final_ratio = (within_group_length/branch_value[1])
	except:		
		try:
			obj_props = [property for property in vars(arch_to_bact_branch_length).iteritems()]
			branch_value = obj_props[1]
			final_ratio = (within_group_length/branch_value[1])
		except:
			print ("Unable to isolate interdomain branch for tree: "+file)
	print (file+": "+str(final_ratio))
