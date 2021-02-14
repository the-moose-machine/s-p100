#!/bin/bash

#This script is used for calculating the returns for a 1 minute interval and exporting a libsvm file
#Export Return, 1:LogChangeInVol 2:Imbalance

# Run this with
# $ ./calculatereturn.sh companyNo timeperiod(format:HHMMSS)
#*****FIND OUT HOW TO LIMIT THE RETURN TO 2 DECIMAL PLACES*****

OLDIFS=$IFS
IFS=","
TimePeriod=$2
CompNo=$1
MergdFile="/home/hduser/Documents/data/Interim/Merged/"$CompNo"merged.csv"
#MergdFileNH="/home/hduser/Documents/data/Interim/Merged/"$CompNo"mergedNH.csv"
echo "MergdFile = $MergdFile"
RtrnFile="/home/hduser/Documents/data/Interim/Returns/"$CompNo"_$TimePeriod.csv"
echo "RtrnFile = $RtrnFile"
#FileName="25_$TimePeriod.csv" #***** CHANGE THIS ******
#Initiatialise flags
PrevAvgPrice=1 # This value has been selected since Natural Log(1)=0
PrevVol=1 # This value has been selected since Natural Log(1)=0
PrevImb=0
CurrTotalTrades=0
CurrTotalPrice=0
CurrTotalVol=0

# *****DON'T DELETE THE HEADER SINCE THIS WILL BE RUN MULTIPLE TIMES AND WILL DELETE THE FIRST ROW ON EACH RUN *****

#sed 1d $MergdFile > $MergdFileNH


while read CurrTS avgPrice volume noOfTrades imbalance
do

	printf "\r%s " $CurrTS
	if (( $CurrTS % $TimePeriod != 0 ));
	then

		#if ! echo "$avgPrice" | egrep -q '^\-?[0-9]*\.?[0-9]+$'; #Check if entry is not a number
		#then
			#echo "avgPrice = $avgPrice which is not a number .... continuing iteration. CurrTS=$CurrTS"
			#continue
		#fi


		# Add Values for totalsale, totalvolume, totaltrades
		#CurrTotalPrice = CurrTotalPrice + (avgPrice * noOfTrades)
		if ( echo $avgPrice | egrep -q '^\-?[0-9]*\.?[0-9]+$' ) && ( echo $noOfTrades | egrep -q '^\-?[0-9]*\.?[0-9]+$' ); #Check if entry is not a number
		then
			#echo "Both avgPrice nor noOfTrades are numbers"
			CurrTotalPrice=`echo "$CurrTotalPrice + ($avgPrice * $noOfTrades)" | bc -l`
			CurrTotalTrades=`echo "$CurrTotalTrades + $noOfTrades" | bc -l`
			CurrTotalVol=`echo "$CurrTotalVol + $volume" | bc -l`
		fi

		#CurrTotalPrice=`echo "$CurrTotalPrice + ($avgPrice * $noOfTrades)" | bc -l`
		#CurrTotalVol=`echo "$CurrTotalVol + $volume" | bc -l` # What is this for?
		#CurrTotalTrades = CurrTotalTrades + noOfTrades
		#CurrTotalTrades=`echo "$CurrTotalTrades + $noOfTrades" | bc -l`
		#echo "CurrTS=$CurrTS, CurrTotalPrice=$CurrTotalPrice, CurrTotalVol=$CurrTotalVol, CurrTotalTrades=$CurrTotalTrades" # ************TESTING*************

	else
		
		#if ! echo "$avgPrice" | egrep -q '^\-?[0-9]*\.?[0-9]+$'; #Check if entry is not a number
		#then
			#echo "avgPrice = $avgPrice which is not a number .... continuing iteration. CurrTS=$CurrTS"
			#continue
		#fi

	#******Check Zero error******

		#******If yes then continue/break (which one to get out of if conditional?)******

	#Calculate figures (Lagged Return, Log Change in Volume)
	#CurrAvgPrice = CurrTotalPrice / CurrTotalTrades



		if [[ $CurrTotalTrades == 0 ]]; # Catch zero division error premptively
		then
			#echo "CurrTotalTrades is equal to zero .... continuing iteration. CurrTS=$CurrTS"
			continue # Read the next line. Perhaps export previous figures here?
		fi

	CurrAvgPrice=`echo "$CurrTotalPrice / $CurrTotalTrades" | bc -l`
	#Return = Ln(CurrAvgPrice) - Ln(PrevAvgPrice)
	Return=`echo "scale=4; l($CurrAvgPrice)-l($PrevAvgPrice)" | bc -l` # Limited to 4 decimal places since this is being used as a classifier.
	#LogChgVol = Ln(CurrTotalVol) - Ln(PrevVol)
	LogChgVol=`echo "l($CurrTotalVol)-l($PrevVol)" | bc -l`

	#******Export figures in libsvm format (Lagged Return, Log Change in Volume, Imbalance)******
	if [[ $Return != 0 ]] && [[ $LogChgVol != 0 ]] && [[ $imbalance != $PrevImb ]]; 
	then 
		echo "CurrTS=$CurrTS; Exporting '$CurrTS,$Return,$LogChgVol,$imbalance'" # ************TESTING*************
		echo "$CurrTS,$Return,$LogChgVol,$imbalance" >> $RtrnFile # For exporting CSV format with Time Stamp for comparison purposes
		#echo "$Return 1:$LogChgVol 2:$imbalance" >> $RtrnFile # For exporting LIBSVM format. This does not have the Time Stamp
	fi

	#echo "CurrTS=$CurrTS; Exporting '$Return 1:$LogChgVol 2:$imbalance'" # ************TESTING*************
	#echo "$Return 1:$LogChgVol 2:$imbalance" >> $RtrnFile
	

	#Save flags for the next iteration
	PrevAvgPrice=$CurrAvgPrice
	PrevVol=$CurrTotalVol
	PrevImb=$imbalance

	fi

done < $MergdFile

printf "\n"
IFS=$OLDIFS
