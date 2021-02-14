# S&P 100
This project predicted the return of a single company from the S&P100 index of the New York Stock Exchange. The data set consisted of microsecond-level transactions of all 100 companies belonging to this index; however, only one of these companies was chosen for analysis.

## Architecture
The full data set was 180 GB in size and therefore needed to be analysed using a cluster of 4 computers. The cluster was formatted into HDFS.

## Data Extraction
Data extraction was done using Bash. 

## Data Transformation
Data transformation was also done using Bash scripts and a single Python script. Bash tools were used on an experimental basis and the process was very time consuming and rough. This project was a proof of concept that Bash scripting can be used for ETL operations for big data. However, the author does not recommend this method for industrial applications.


## Data Loading
Data was loaded into HDFS from the command line.

## Model Training
Model training was done using Spark Standalone using Scala scripts. Models included Decision Trees, Naive Bayes, Support Vector Machine and Linear Regression.
