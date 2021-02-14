package mining

import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql._
import com.databricks.spark.csv
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType, DateType, TimestampType, DoubleType, LongType};
import breeze.linalg._
import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors

object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("KMeans 2.csv 10 to 50 clusters")
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    val pathToFile = "hdfs://hadoopmaster:9000/user/hive/warehouse/condensed/2.csv" 
    val minK = 10
    val maxK = 500
    val incrementK = 10
    val numIterations = 200
    val maxDimensions = maxK/incrementK.toInt
    val results = Array.ofDim[Double](maxDimensions,2)
    var j = 0
    var WSSSE=0.0

    println("Reading data...")

    val data = sc.textFile(pathToFile) // For Iris Data set

    println("Parsing data...")

    val parsedData = data.map(s => Vectors.dense(s.split(',').map(_.toDouble))).cache() 

    //Run multiple iterations of K

    for(i <- minK to maxK by incrementK){
      
      results(j)(0) = i

      // Cluster the data into twenty classes using KMeans
      //val numClusters = 150


      println("Calculating KMeans...")

      val clusters = KMeans.train(parsedData, i, numIterations) 

      println("Calculating WSSSE for " + i + " clusters")

      // Evaluate clustering by computing Within Set Sum of Squared Errors
      WSSSE = clusters.computeCost(parsedData)

      //println("Within Set Sum of Squared Errors = " + WSSSE)
      results(j)(1) = WSSSE
      j += 1

    }

    for {i <- 0 until maxDimensions
         j <- 0 until 1
      } println(s"K, WSSSE = ${results(i)(j)}, ${results(i)(j+1)}")

    // Save and load model
    //clusters.save(sc, "myModelPath")
    //val sameModel = KMeansModel.load(sc, "myModelPath")

  }
}
