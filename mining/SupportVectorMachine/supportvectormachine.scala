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
import java.io.PrintWriter
import java.io.FileWriter


object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("SVM Test with AAPL data")
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    // Load training data in LIBSVM format.
    println("Loading data...")
    val data = MLUtils.loadLibSVMFile(sc, "hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2libsvmint.scale") // The system does not load the data throwing an error java.lang.NumberFormatException: For input string: "1:94.56"
    //val data = MLUtils.loadLabeledPoints(sc, "hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2libsvmint.scale")

    // Split data into training (60%) and test (40%).
    println("Splitting data...")
    val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0).cache()
    val test = splits(1)

    // Run training algorithm to build the model
    val numIterations = 100
    println("Running training model...")
    val model = SVMWithSGD.train(training, numIterations)

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
