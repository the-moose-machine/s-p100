#Data Mining on Spark Standalone using Scala
This is a sample of a mining code used in this project.

First compile the package with sbt
```
$ sbt package
```
Follow this up with the `spark-submit` code. For example as provided below. Please note that the path has to be adjusted to reflect the location of the jar file in your machine.
```
spark-submit \
--packages com.databricks:spark-csv_2.11:1.4.0 \
--master local[4] \
'/home/hduser/Documents/data/Test/maven/testloadcsvdata/target/scala-2.10/loadtestcsvdata_2.10-1.0-SNAPSHOT.jar' 
```

The following models were trained:
* Naive Bayes
* Decision Trees
* Linear Regression
* Support Vector Machine
