#!/bin/bash

# This script is executed as $./batchmerge.sh

# Find all the companies within the folder

DepthLocation="/home/hduser/Documents/data/Extracted/Constituents_depth/"

ls -a $DepthLocation | while read companyFile; 
	do 
		company=`echo $companyFile | cut -d\. -f1;`

		# If: companyNo is not a number then continue
		if ! echo "$company" | egrep -q '^\-?[0-9]*\.?[0-9]+$'; 
		then 
			continue
		else
			# Else: start merging the company
			echo "Exporting key figures for " $company "..."
			./exportkeyfigures.sh $company # Export the key figures of this company
			echo "Done"
			echo "Calculating imbalance for " $company "..."
			./calculateimbalance.sh $company # Calculate the imbalance of this company
			echo "Done"
			echo "Merging datasets for " $company
			python3 mergebases.py $company
			echo "Done"
		fi

	done
