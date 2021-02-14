name := "mining"

version := "1.0-SNAPSHOT"

scalaVersion := "2.10.5"

unmanagedBase <<= baseDirectory { base => base / "lib" }

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.6.1"
libraryDependencies += "org.apache.spark" % "spark-sql_2.10" % "1.6.1"
// https://mvnrepository.com/artifact/org.apache.spark/spark-mllib_2.10
libraryDependencies += "org.apache.spark" % "spark-mllib_2.10" % "1.6.2"
// https://mvnrepository.com/artifact/com.databricks/spark-csv_2.11
libraryDependencies += "com.databricks" % "spark-csv_2.11" % "1.4.0"
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "2.7.2"
libraryDependencies  ++= Seq(
  // Last stable release
  "org.scalanlp" %% "breeze" % "0.12",

  // Native libraries are not included by default. add this if you want them (as of 0.7)
  // Native libraries greatly improve performance, but increase jar sizes. 
  // It also packages various blas implementations, which have licenses that may or may not
  // be compatible with the Apache License. No GPL code, as best I know.
  "org.scalanlp" %% "breeze-natives" % "0.12",

  // The visualization library is distributed separately as well.
  // It depends on LGPL code
  "org.scalanlp" %% "breeze-viz" % "0.12"
)


resolvers += "Sonatype Releases" at "https://oss.sonatype.org/content/repositories/releases/"

organization := "ac.nz.whitireia"

