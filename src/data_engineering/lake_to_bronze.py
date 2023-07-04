# Databricks notebook source
dbutils.widgets.text("source_path", "")
dbutils.widgets.text("target_table", "")
dbutils.widgets.text("format", "")
dbutils.widgets.text("checkpoint_path", "")
dbutils.widgets.text("schema_path", "")
dbutils.widgets.text("target_catalog", "")
dbutils.widgets.text("target_database", "")

# COMMAND ----------

print("Input parameters:")
print("----------------")
print(f"> Checkpoint path: {getArgument('checkpoint_path')}")
print(f"> Schema path: {getArgument('schema_path')}")
print(f"> Source path: {getArgument('source_path')}")
print(f"> Format: {getArgument('format')}")
print(f"> Target catalog: {getArgument('target_catalog')}")
print(f"> Target database: {getArgument('target_database')}")
print(f"> Target table: {getArgument('target_table')}")

# COMMAND ----------

import pyspark.sql.functions as F

# COMMAND ----------

# Set up the stream to begin reading incoming files from the autoloader_ingest_path location.
df = spark.readStream.format('cloudFiles') \
  .option('cloudFiles.format', getArgument("format")) \
  .option('cloudFiles.schemaLocation', getArgument("schema_path")) \
  .load(getArgument("source_path")) \
  .withColumn("file_path",F.input_file_name()) \
  .withColumn("inserted_at", F.current_timestamp()) 

batch_autoloader = df.writeStream \
  .format('delta') \
  .outputMode("append") \
  .option('checkpointLocation', getArgument("checkpoint_path")) \
  .option("mergeSchema", "true") \
  .trigger(once=True) \
  .table(f"{getArgument('target_catalog')}.{getArgument('target_database')}.{getArgument('target_table')}")

batch_autoloader.awaitTermination()
