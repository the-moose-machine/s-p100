#!/usr/bin/env python3
import pandas as pd
import sys

# The script has to be passed as follows:
# $ python3 mergebases.py <companyNo>

def main():
	companyNo = sys.argv[1]
	intradayFile = "/home/hduser/Documents/data/Interim/IntradayBase/" + companyNo + "baseintraday.csv"
	imbalanceFile = "/home/hduser/Documents/data/Interim/Imbalance/" + companyNo + "imbalance.csv"
	mergedFile = "/home/hduser/Documents/data/Interim/Merged/" + companyNo + "merged.csv"
	a = pd.read_csv(intradayFile)
	b = pd.read_csv(imbalanceFile)
	merged = a.merge(b, on='time')
	merged.to_csv(mergedFile, index=False)

if ( __name__ == "__main__" ):
	main()
