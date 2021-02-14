#!/bin/bash

# Run this with
# $ ./calculateimbalance.sh companyNo

OLDIFS=$IFS
IFS=","
CompanyNo=$1
DepthFile="/home/hduser/Documents/data/Extracted/Constituents_depth/"$CompanyNo".csv"
echo "DepthFile = "$DepthFile
ImbalanceFile="/home/hduser/Documents/data/Interim/Imbalance/"$CompanyNo"imbalance.csv"
echo "ImbalanceFile = "$ImbalanceFile
#Initialize variables
FlagTS=20160101000000 #TimeStamp (TS) format should be YYMMDDHHMMSS
FlagImb=0 

# First export the header for future merging
echo "time,imbalance" > $ImbalanceFile

#Initialise previous figures (lap1, las1, lbp1, lbp2 etc)

while read RIC dt ti go ty bp1 bs1 ap1 as1 bp2 bs2 ap2 as2 bp3 bs3 ap3 as3 bp4 bs4 ap4 as4 bp5 bs5 ap5 as5 bp6 bs6 ap6 as6 bp7 bs7 ap7 as7 bp8 bs8 ap8 as8 bp9 bs9 ap9 as9 bp10 bs10 ap10 as10
do
	# Check if input is not numerical, then "continue" 
	printf "\r%s %s" $dt $ti
	if ! echo "$bp1" | egrep -q '^\-?[0-9]*\.?[0-9]+$'; then 
		#CurrImb=$FlagImb
		continue
	fi

	# Calculate current imbalance and catch zero error, if it exists then "continue"
	#Calculate Ma & Mb: d=`echo "$a+7/8-($b*$c)" | bc -l`
	Ma=`echo "($ap1 + $ap2)/2" | bc -l`
	Mb=`echo "($bp1 + $bp2)/2" | bc -l`
	if [[ $Ma == 0 ]] || [[ $Mb == 0 ]]; # Catch zero division error premptively
	then
		continue
	fi

	#Calculate ΣQal & ΣQbl
	SQal=`echo "$as1+$as2+$as3+$as4+$as5+$as6+$as7+$as8+$as9+$as10" | bc -l`
	SQbl=`echo "$bs1+$bs2+$bs3+$bs4+$bs5+$bs6+$bs7+$bs8+$bs9+$bs10" | bc -l`
	if [[ $SQal == 0 ]] || [[ $SQbl == 0 ]]; # Catch zero division error premptively
	then
		continue
	fi

	#Calculate VLMal & VLMbl
	VLMal=`echo "($ap1 * $as1) + ($ap2 * $as2) + ($ap3 * $as3) + ($ap4 * $as4) + ($ap5 * $as5) + ($ap6 * $as6) + ($ap7 * $as7) + ($ap8 * $as8) + ($ap9 * $as9) + ($ap10 * $as10)" | bc -l`
	VLMbl=`echo "($bp1 * $bs1) + ($bp2 * $bs2) + ($bp3 * $bs3) + ($bp4 * $bs4) + ($bp5 * $bs5) + ($bp6 * $bs6) + ($bp7 * $bs7) + ($bp8 * $bs8) + ($bp9 * $bs9) + ($bp10 * $bs10)" | bc -l`
	if [[ $VLMal == 0 ]] || [[ $VLMbl == 0 ]]; # Catch zero division error premptively
	then
		continue
	fi

	#Calculate VWAPMal & VWAPMbl. 
	VWAPMal=`echo "l($VLMal / $SQal / $Ma)" | bc -l`
	VWAPMbl=`echo "l($VLMbl / $SQbl / $Mb)" | bc -l`

	#Calculate MCIa & MCIb
	MCIa=`echo "$VWAPMal / $VLMal" | bc -l`
	MCIb=`echo "-($VWAPMbl / $VLMbl)" | bc -l`

	#Calculate CurrImb (also known as MCIimb)
	CurrImb=`echo "($MCIa - $MCIb) / ($MCIa + $MCIb)" | bc -l`

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

	if (( $CurrTS > $FlagTS )); # check if the new time value is greater than the previous timevalue
	then 
		if (( $CurrTS == $FlagTS+1 )); # Check if the TimeStamp is the next logical one
		then
			# Export FlagTS,FlagImb to csv file
			echo "$FlagTS,$FlagImb" >> $ImbalanceFile # ******** CHANGE THIS ********
			#echo "$FlagTS,$FlagImb,$MCIb,$MCIa,$VWAPMbl,$VWAPMal,$VLMbl,$VLMal,$SQbl,$SQal,$Mb,$Ma" >> $ImbalanceFile # ******** CHANGE THIS ********
			FlagTS=$CurrTS 

		else
			# Loop to add time values for each second
			for (( i=$FlagTS; i<$CurrTS; i++ ))
			do
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

				# Export i,FlagImb to csv file
				echo "$i,$FlagImb" >> $ImbalanceFile # ******** CHANGE THIS ********
				#echo "$i,$FlagImb,$MCIa,$MCIb,$VWAPMbl,$VWAPMal,$VLMbl,$VLMal,$SQbl,$SQal,$Mb,$Ma" >> $ImbalanceFile # ******** CHANGE THIS ********

			done

		FlagTS=$CurrTS

		fi
	
	fi

	FlagImb=$CurrImb

done < $DepthFile

# ********* IF CurrTS(time only) < 11:59:59 pm THEN CONTINUE ITERATION WITH THE FlagImb till the end of the day ***********
# Previously the last entry for 25imbalance.csv was 20160105210010,-.72975670859798452029
# Extract the time only for CurrTS
LastTime=`echo ${FlagTS:8:6}`
LastDate=`echo ${FlagTS:0:8}`
#echo "FlagTS=$FlagTS, CurrTS=$CurrTS, LastTime=$LastTime, LastDate=$LastDate, FlagImb=$FlagImb, CurrImb=$CurrImb"

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
		#echo "$i,$FlagImb"
		# Export i,FlagImb to csv file
		echo "$i,$FlagImb" >> $ImbalanceFile # ******** CHANGE THIS ********
		#echo "$i,$FlagImb,$MCIa,$MCIb,$VWAPMbl,$VWAPMal,$VLMbl,$VLMal,$SQbl,$SQal,$Mb,$Ma" >> $ImbalanceFile # ******** CHANGE THIS ********
		j=$(($j + 1))

	done


fi

printf "\n"
IFS=$OLDIFS
