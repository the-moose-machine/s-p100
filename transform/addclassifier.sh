#!/bin/bash

#This script is used for adding the classifier to the merged data and then exporting it as a libsvm file
#Export Return, 1:AvgPrice 2:Volume 3:Imbalance

# Run this with
# $ ./addclassifier.sh companyNumber timeperiod(hhmmss)

#Initiatialise flags
OLDIFS=$IFS
IFS=","
CompanyNo=$1
TimePeriod=$2
ReturnFile="/home/hduser/Documents/data/Interim/Returns/"$CompNo"_$TimePeriod.csv"
MergedFile="/home/hduser/Documents/data/Interim/Merged/"$CompNo"mergedNH.csv"
TargetFile="/home/hduser/Documents/data/Interim/Classifiers/$CompanyNo""_$TimePeriod.libsvm"
i=1
j=1

# Save ReferenceTimeStamps and Returns
while read CurrTS Return LogChgVol imbalance
do
	RefTS[$i]=$CurrTS #Save all referenced TimeStamps in an array
	Return[$i]=$Return #Save all Calculated Returns for a particular TimeStamp in another array
	i=$((i+1))
	printf "\r%s " $i
done < $ReturnFile

echo " "

#echo -e "RefTS[$i]=${RefTS[i]}\nReturn[$i]=${Return[i]}"
#exit 1 # Only for testing purposes

# READ MERGED FILE
while read CurrTS avgPrice volume noOfTrades imbalance
do
	#printf "\r%d " $j
	printf "\r%s " $CurrTS
	if  [[ $CurrTS -le ${RefTS[$j]} ]]; # Check if the Current TimeStamp is within the Reference TimeStamp limit
	then
		#Export details under the Currently Referenced TimeStamp:: $Return[$j] 1:$avgPrice 2:$volume $imbalance
		if [[ $avgPrice != "" ]] && [[ $volume != "" ]];
		then
			echo -n "${Return[$j]} " >> $TargetFile
		else
			continue
		fi

		if [[ $avgPrice != "" ]];
		then
			echo -n "1:$avgPrice " >> $TargetFile
		fi

		if [[ $volume != "" ]];
		then
			echo -n "2:$volume " >> $TargetFile
		fi

		if [[ $noOfTrades != "" ]];
		then
			echo -n "3:$noOfTrades " >> $TargetFile
		fi

		echo "4:$imbalance" >> $TargetFile

	else
		#Increment index j
		#j=$((j+1))
		((++j))

		#Export details under the Next Referenced TimeStamp
		if [[ $avgPrice != "" ]] && [[ $volume != "" ]];
		then
			echo -n "${Return[$j]} " >> $TargetFile
		else
			continue
		fi

		#echo -n "${Return[$j]} " >> $TargetFile

		if [[ $avgPrice != "" ]];
		then
			echo -n "1:$avgPrice " >> $TargetFile
		fi

		if [[ $volume != "" ]];
		then
			echo -n "2:$volume " >> $TargetFile
		fi

		if [[ $noOfTrades != "" ]];
		then
			echo -n "3:$noOfTrades " >> $TargetFile
		fi

		echo "4:$imbalance" >> $TargetFile
	fi

done < $MergedFile

printf "\n"
IFS=$OLDIFS
