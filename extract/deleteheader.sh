#! /bin/bash
# Run this script as follows:
# $ ./deleteheader.sh originaldirectory targetdirectory

cd $1
#folder="/media/hduser/a2ff5149-f422-4b16-a0fa-6d6901416b3d/FormattedData"
folder=$2
totalFiles=`ls | wc -l`
totalCompanies=$(($totalFiles - 1));

for (( i=1; i <= $totalCompanies; ++i ))
do
	sed 1d ${i}.csv > /${folder}/${i}.csv
done
