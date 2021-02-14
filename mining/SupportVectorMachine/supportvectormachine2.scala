package mining

import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql._
import com.databricks.spark.csv
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType, DateType, TimestampType, DoubleType, LongType};
import breeze.linalg._
//import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.classification.{SVMModel, SVMWithSGD}
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import java.io.PrintWriter
import java.io.FileWriter


object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("SVM with alt reading for AAPL ")
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    // Load training data in LIBSVM format.
    println("Loading data...")
    val data = sc.textFile("hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2Fortnight.libsvm")
    val parsedData = data.map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache() // Is this correct? Should this be done in lines 38 and 39 / 52 instead?

    // Split data into training (80%) and test (20%).
    println("Splitting data...")
    val splits = parsedData.randomSplit(Array(0.8, 0.2), seed = 11L)
    val training = splits(0).cache()
    val test = splits(1)

    // Run training algorithm to build the model
    val numIterations = 100
    println("Running training model...")
    val model = SVMWithSGD.train(training, numIterations)
/*
 ERROR util.DataValidators: Classification labels should be 0 or 1. Found 1954346 invalid labels
Exception in thread "main" org.apache.spark.SparkException: Input validation failed.
*/


    // Clear the default threshold.
    println("Clearing threshold...")
    model.clearThreshold()

    // Compute raw scores on the test set.
    println("Computing raw scores on the test...")
    val scoreAndLabels = test.map { point =>
      val score = model.predict(point.features)
      (score, point.label)
      }

    // Get evaluation metrics.
    println("Getting evaluation metrics...")
    val metrics = new BinaryClassificationMetrics(scoreAndLabels)
    val auROC = metrics.areaUnderROC()

    println("Area under ROC = " + auROC)

    // Save and load model
    //model.save(sc, "myModelPath")
    //val sameModel = SVMModel.load(sc, "myModelPath")

  }
}
