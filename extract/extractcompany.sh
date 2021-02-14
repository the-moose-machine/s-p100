#! /bin/bash
# Run this with ./extractcompany.sh
# This script is used for extracting data from company number 19
# Change the company number when experimenting with other companies
companyNo=19
awk -F, '{ print $1 }' /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/SP100_DATA/Constituents_Time_Sales/ihsan.badshah@aut.ac.nz-OEXA_Constituents_Time_Sales-N113412694-part004.csv | uniq > /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/4/allCompanies
totalCompanies=`wc -l /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/4/allCompanies | grep [0-9] | awk '{ print $1 }'`
finalTotalCompanies=$(($companyNo + $totalCompanies))

for company in `cat /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/4/allCompanies`;
do	
	echo "$companyNo $company"
	
	if [ $companyNo -gt 0 ];
	then
		cat /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/0.csv > /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/4/${companyNo}.csv
	fi
	
	grep ${company} /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/SP100_DATA/Constituents_Time_Sales/ihsan.badshah@aut.ac.nz-OEXA_Constituents_Time_Sales-N113412694-part004.csv >> /media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/Extracted/Constituents_Time_Sales/4/${companyNo}.csv

	companyNo=$(($companyNo + 1));

	if [ $companyNo -gt $finalTotalCompanies ];
	then 
		exit
	echo "Done!"
	fi

done
