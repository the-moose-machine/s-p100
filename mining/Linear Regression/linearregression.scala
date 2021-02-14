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
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
import java.io.PrintWriter
import java.io.FileWriter

// *** THIS RUNS OK BUT HOW TO PREDICT?

object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("Regression Test with AAPL data") 
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    // Load and parse the data
    println("Loading data...")
    val data = sc.textFile("hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2regression.data")
    println("Parsing data...")
    val parsedData = data.map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }.cache()

    // Building the model
    println("Building the model...")
    val numIterations = 100
    val stepSize = 0.00000001
    val model = LinearRegressionWithSGD.train(parsedData, numIterations, stepSize)

    // Evaluate model on training examples and compute training error
    println("Evaluating model...")
    val valuesAndPreds = parsedData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }

    val MSE = valuesAndPreds.map{case(v, p) => math.pow((v - p), 2)}.mean()
    println("training Mean Squared Error = " + MSE) // training Mean Squared Error = 2.5374370593032185E10


  }
}
