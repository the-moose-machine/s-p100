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
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.tree.model.DecisionTreeModel
//import org.apache.spark.mllib.util.MLUtils
import java.io.PrintWriter
import java.io.FileWriter



object mining {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("Decision Tree AAPL Daily Depth30 Bins47 Entropy")
    val sc = new SparkContext(conf)
    val sqlContext = new SQLContext(sc)

    // Load and parse the data file.
    println("Loading data...")
    //val data = sc.textFile("hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2FortnightComma.libsvm")
    val data = MLUtils.loadLibSVMFile(sc, "hdfs://hadoopmaster:9000/user/hive/warehouse/libsvm/2DailyClassNo.libsvm")

    //println("Parsing data...")
    //val parsedData = data.map { line =>
      //val parts = line.split(',')
      //LabeledPoint(parts(0).toDouble, Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    //}.cache() 

    // Split the data into training and test sets (20% held out for testing)
    println("Splitting data...")
    //val splits = parsedData.randomSplit(Array(0.8, 0.2))
    val splits = data.randomSplit(Array(0.8, 0.2))
    val (trainingData, testData) = (splits(0), splits(1))

    // Train a DecisionTree model.
    //  Empty categoricalFeaturesInfo indicates all features are continuous.
    val numClasses = 48 // There are 10 classes in the weekly data
    val categoricalFeaturesInfo = Map[Int, Int]()
    val impurity = "entropy" // *** ERROR: GiniAggregator given label 96.71 but requires label < numClasses (= 10). REFORMAT CLASSES TO NUMBERS 0-9
    val maxDepth = 30 // DecisionTree currently only supports maxDepth <= 30
    val maxBins = 48 // Original: 32
    val maxMemoryInMB = 160227 // This has not been included in the algorithm below.

    println("Training Model...")
    //val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo, impurity, maxDepth) 
    //val model = DecisionTree.trainRegressor(trainingData, categoricalFeaturesInfo, impurity, maxDepth, maxBins)
    val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo, impurity, maxDepth, maxBins)


    // Evaluate model on test instances and compute test error
    println("Running predictions...")
    val labelAndPreds = testData.map { point =>
      val prediction = model.predict(point.features)
      (point.label, prediction)
    }
    val testErr = labelAndPreds.filter(r => r._1 != r._2).count().toDouble / testData.count()
    println("Test Error = " + testErr)
    //println("Learned classification tree model:\n" + model.toDebugString)

// Save and load model
//model.save(sc, "target/tmp/myDecisionTreeClassificationModel")
//val sameModel = DecisionTreeModel.load(sc, "target/tmp/myDecisionTreeClassificationModel")

  }
}
