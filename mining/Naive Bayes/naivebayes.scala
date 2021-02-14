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
import org.apache.spark.mllib.regression.LabeledPoint
//import org.apache.spark.mllib.regression.LinearRegressionModel
//import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}
import java.io.PrintWriter
import java.io.FileWriter

// *** THIS RUNS OK BUT RUN IT WITH 2naivebayes.data NEXT TIME. LOAD IT INTO HDFS FIRST **

object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("Naive Bayes AAPL Test") 
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    // Load and parse the data
    println("Loading data...")
    val data = sc.textFile("hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2naivebayes.data") // Naive Bayes format

    println("Parsing data...")
    val parsedData = data.map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }

    // Split data into training (80%) and test (20%).
    println("Splitting data...")
    val splits = parsedData.randomSplit(Array(0.8, 0.2), seed = 13L)
    val training = splits(0)
    val test = splits(1)

    println("Running Naive Bayes...")
    val model = NaiveBayes.train(training, lambda = 1.0, modelType = "multinomial")

    val predictionAndLabel = test.map(p => (model.predict(p.features), p.label))

    println("Calculating accuracy...")
    val accuracy = 100.0 * predictionAndLabel.filter(x => x._1 == x._2).count() / test.count() // This takes a long time to compute for AAPL - 3.2 HOURS. Accuracy = 0.0010156302737599186

    println("Accuracy = " + accuracy)

// Save and load model
model.save(sc, "/user/hive/warehouse/libsvm/AAPLNaiveBayesModel2")
//val sameModel = NaiveBayesModel.load(sc, "target/tmp/myNaiveBayesModel")

  }
}
