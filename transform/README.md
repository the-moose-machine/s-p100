#Transform data

Data transformation requires the merging of various tables. This can be done as follows.
1. First merge the data of all companies within the folder with `batchmerge.sh`
1. Export the key figures for each second of transaction from the Interday data and format them for each second using `exportkeyfigures.sh`
2. Calculate the imbalance with `calculateimbalance.sh`
3. Merge tables using `mergebases.py`
4. Merge two CSV files on the basis of their timestamps with `mergebases.py`
5. Calculate the return over 1 minute time intervals with `calculatereturn.sh`
5. Finally, add the classifier with `addclassifier.sh`
