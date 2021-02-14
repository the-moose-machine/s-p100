#!/bin/bash

#This script is used for exporting the key figures for each second from the Intraday data.
#Export TimeStamp as Integer, Avg Price, Volume, No of Trades

# Run this with
# $ ./exportkeyfigures.sh companyNo

OLDIFS=$IFS
IFS=","
CompanyNo=$1
IntradayFile="/home/hduser/Documents/data/Extracted/Constituents_intraday_data_1sec/"$CompanyNo".csv"
echo "IntradayFile = "$IntradayFile
IntradayBaseFile="/home/hduser/Documents/data/Interim/IntradayBase/"$CompanyNo"baseintraday.csv"
echo "IntradayBaseFile = "$IntradayBaseFile
#FileName=$CompanyNo"baseintraday.csv"

FlagTS=20160101000000 #TimeStamp (TS) format should be YYMMDDHHMMSS. This should indicate the first time stamp for the data

# First export the header for future merging
echo "time,avgPrice,volume,noOfTrades" > $IntradayBaseFile 

#Iterate through the Intraday data file
while read RIC dt ti go ty opp hip lop lstp vol avgp vwap trades ob hb lb cb nb oa ha la ca na
do
	# Check if input is not numerical, then "continue" 
	printf "\r%s %s" $dt $ti
	if ! echo "$trades" | egrep -q '^\-?[0-9]*\.?[0-9]+$'; 
	#if [[ $trades == "" ]];
	then
		#CurrImb=$FlagImb
		continue
	fi

	# Extract Time and Date
	tim=`echo ${ti:0:8} | tr -d :` # extract the full time string up to the second
	timsec=`echo $tim | cut -c5-6` # Seconds
	timmin=`echo $tim | cut -c3-4` # Minutes
	timhr=`echo $tim | cut -c1-2` # Hours
	dtd=`echo ${dt%%\-*}` # Date
	dtms=`echo $dt | cut -c4-6` # extract the month as a string

	# Calculate the Month (The year is 2016 for this dataset)
	case $dtms in
		JAN) dtmn=01;;
		FEB) dtmn=02;;
		MAR) dtmn=03;;
		APR) dtmn=04;;
		MAY) dtmn=05;;
		JUN) dtmn=06;;
		JUL) dtmn=07;;
		AUG) dtmn=08;;
		SEP) dtmn=09;;
		OCT) dtmn=10;;
		NOV) dtmn=11;;
		DEC) dtmn=12;;
	esac

	CurrTS=`echo 2016$dtmn$dtd$tim` #Current Time Stamp
	#echo "trades=$trades which is a number; FlagTS=$FlagTS; CurrTS=$CurrTS"


	#Check if CurrTS = FlagTS+1, then export the figures, else go into a loop to add blanks to each second until the CurrTS.
	if (( $CurrTS == $FlagTS+1 )); # Check if the TimeStamp is the next logical one
	then
		if (( $SecondFlag == $CurrTS-1 ));
		then
			echo "$SecondFlag,,," >> $IntradayBaseFile # Export the empty sandwiched row
		fi
		# Export FlagTS,FlagImb to csv file
		echo "$CurrTS,$avgp,$vol,$trades" >> $IntradayBaseFile

		FlagTS=$CurrTS 
		ThirdFlag=$CurrTS # This is required to not duplicate a time stamp that has already been exported

	else
		# Loop to add time values for each second
		for (( i=$FlagTS; i<$CurrTS; i++ ))
		do
			if [[ $ThirdFlag == $i ]];
			then
				continue # Skip the already exported row
			fi

			#Split i into sec, min, hr, dt and month
			isec=`echo ${i:12:2}` # Seconds in i
			imin=`echo ${i:10:2}` # Minutes in i
			imina=1$imin # This is because Bash gives a weird error if 08 + 1 or 09 + 1 is passed
			ihr=`echo ${i:8:2}` # Hours in i
			ihra=1$ihr
			idt=`echo ${i:6:2}` # Date in i
			idta=1$idt
			imn=`echo ${i:4:2}` # Month in i
			imna=1$imn
			iyr=`echo ${i::4}` # Year in i
			iyra=1$iyr


			#Check validity of seconds, mins, hrs, & date and format i with the corrected date and time
			if [[ $isec == 60 ]];
			then
				imina=10$(($imina + 1))
				imin=`echo ${imina:(-2)}` #Ensure that this is 2 digits starting with 0
				isec=00
			fi
					if [[ $imin == 60 ]];
			then
				ihra=10$(($ihra + 1))
				ihr=`echo ${ihra:(-2)}`
				imin=00
			fi
				if [[ $ihr == 24 ]];
			then
				idta=10$(($idta + 1))
				idt=`echo ${idta:(-2)}`
				ihr=00
			fi
				if [[ $idt == 32 ]];
			then
				imna=10$(($imna + 1))
				imn=`echo ${imna:(-2)}`
				idt=00
			fi

			# Fix i by merging year, month, date, hour, minute and second
			i=$iyr$imn$idt$ihr$imin$isec

			#Check if i = CurrTS, then "continue", skip to avoid duplication
			if [[ $i == $CurrTS ]];
			then
				continue
			fi

			# Export i,,, to csv file, this is a line with blanks for that second
			echo "$i,,," >> $IntradayBaseFile 

		done

		echo "$CurrTS,$avgp,$vol,$trades" >> $IntradayBaseFile 

		FlagTS=$(($CurrTS + 1))
		SecondFlag=$FlagTS # This is required since the loop skips empty rows sandwiched between data

	fi


done < $IntradayFile

# ********* IF CurrTS(time only) < 11:59:59 pm THEN CONTINUE ITERATION WITH THE FlagImb till the end of the day ***********
# Previously the last entry for 25imbalance.csv was 20160105210010,-.72975670859798452029
# Extract the time only for CurrTS
LastTime=`echo ${FlagTS:8:6}`
LastDate=`echo ${FlagTS:0:8}`
#echo "FlagTS=$FlagTS, CurrTS=$CurrTS, LastTime=$LastTime, LastDate=$LastDate"

if (( $LastTime < 235959 ));
then

	for (( j=$LastTime; j<=235959; i++ ))
	do
		#Split i into sec, min, hr, dt and month
		isec=`echo ${j:4:2}` # Seconds in i
		imin=`echo ${j:2:2}` # Minutes in i
		imina=1$imin # This is because Bash gives a weird error if 08 + 1 or 09 + 1 is passed
		ihr=`echo ${j:0:2}` # Hours in i
		ihra=1$ihr
		idt=`echo ${LastDate:6:2}` # Date in i
		idta=1$idt
		imn=`echo ${LastDate:4:2}` # Month in i
		imna=1$imn
		iyr=`echo ${LastDate::4}` # Year in i
		iyra=1$iyr

		#Check validity of seconds, mins, hrs, & date and format i with the corrected date and time
		if [[ $isec == 60 ]];
		then
			imina=$(($imina + 1))
			imin=`echo ${imina:(-2)}` #Ensure that this is 2 digits starting with 0
			isec=00
		fi
	
		if [[ $imin == 60 ]];
		then
			ihra=10$(($ihra + 1))
			ihr=`echo ${ihra:(-2)}`
			imin=00
		fi

		if [[ $ihr == 24 ]];
		then
			idta=10$(($idta + 1))
			idt=`echo ${idta:(-2)}`
			ihr=00
		fi

		if [[ $idt == 32 ]];
		then
			imna=10$(($imna + 1))
			imn=`echo ${imna:(-2)}`
			idt=00
		fi

		# Fix i by merging year, month, date, hour, minute and second
		j=$ihr$imin$isec
		i=$LastDate$j

		# Export i,,, to csv file
		echo "$i,,," >> $IntradayBaseFile 
		j=$(($j + 1))

	done


fi

printf "\n"
IFS=$OLDIFS
