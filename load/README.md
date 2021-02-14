#Load data into HDFS
Load transformed files into the constituenttimesales/RICCodes folder in HDFS using the following command:

```
$ hadoop fs -copyFromLocal path/to/local/file /user/hive/warehouse/constituenttimesales/RICCodes
```
