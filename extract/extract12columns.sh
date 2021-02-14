#! /bin/bash
# Run this script as follows:
# $ ./extract12columns originaldirectory targetdirectory
cd $1
totalFiles=`ls | wc -l`
totalCompanies=$(($totalFiles - 1));

for (( i=0; i <= $totalCompanies; ++i ))
do
	cut -d "," -f1-12 $1/${i}.csv >> $2/CombinedTimeSales.csv
done
