# Databricks notebook source
dbutils.widgets.text("source_path","")
dbutils.widgets.text("schema_path","")
dbutils.widgets.text("checkpoint_path","")

# COMMAND ----------

from pyspark.sql.types import StructField, StructType, StringType, DateType, IntegerType, DoubleType
import pyspark.sql.functions as F

# COMMAND ----------

# define source schema
weather_schema = StructType([
  StructField('uuid', StringType(), True),
  StructField('date', DateType(),True),
  StructField('time', StringType(),True),
  StructField('temperature', IntegerType(),True),
  StructField('weathercode', StringType(),True),
  StructField('windspeed', DoubleType(),True),
  StructField('winddirection',StringType(),True),
  StructField('humidity', DoubleType(),True)
])

# COMMAND ----------

# read stream
df = spark.readStream.schema(weather_schema) \
  .format('cloudFiles') \
  .option('cloudFiles.format', "json") \
  .option('cloudFiles.schemaLocation', getArgument("schema_path")) \
  .load(getArgument("source_path")) \
  .withColumn("file_path",F.input_file_name()) \
  .withColumn("inserted_at", F.current_timestamp()) 

# COMMAND ----------

# MAGIC %md
# MAGIC Following the principle of *"Read once, Write many"*:
# MAGIC 
# MAGIC Write the data to different targets:
# MAGIC - one to a table in its raw format
# MAGIC - second to a table after calculating the daily average temperature
# MAGIC - third to a table after calculating the weekly average temperature
# MAGIC 
# MAGIC This allows minimal IO processing, by reading the data once and writing many times as required

# COMMAND ----------


# write data to delta table in its raw format
df.writeStream \
  .format('delta') \
  .outputMode("append") \
  .option('checkpointLocation', f"{getArgument('checkpoint_path')}_raw") \
  .option("mergeSchema", "true") \
  .trigger(processingTime="5 seconds") \
  .table(f"renjiharold_demo.poc.weather_raw")



# COMMAND ----------

# aggregate data
daily_avg_df = df.groupBy(df.date.alias("date_recorded")) \
           .agg(F.round(F.avg("temperature"),1).alias("avg_temp"))

# COMMAND ----------

# write data to delta table in aggregated format
daily_avg_df.writeStream \
  .format('delta') \
  .outputMode("complete") \
  .option('checkpointLocation', f"{getArgument('checkpoint_path')}_agg_daily") \
  .option("mergeSchema", "true") \
  .trigger(processingTime="5 seconds") \
  .table(f"renjiharold_demo.poc.weather_daily_avg_temp_gold")

# COMMAND ----------

weekly_avg_df = df \
  .groupBy(F.window(df.date, "7 days")) \
  .agg(F.round(F.avg("temperature"),1).alias("avg_temp"))

# COMMAND ----------

# write data to delta table in aggregated format
weekly_avg_df.writeStream \
  .format('delta') \
  .outputMode("complete") \
  .option('checkpointLocation', f"{getArgument('checkpoint_path')}_agg_weekly") \
  .option("mergeSchema", "true") \
  .trigger(processingTime="5 seconds") \
  .table(f"renjiharold_demo.poc.weather_weekly_avg_temp_gold")

# COMMAND ----------


