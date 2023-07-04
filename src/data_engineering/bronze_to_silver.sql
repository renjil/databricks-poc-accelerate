-- Databricks notebook source
-- MAGIC %python
-- MAGIC dbutils.widgets.text("target_catalog", "")
-- MAGIC dbutils.widgets.text("target_database", "")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(f"> Target catalog: {getArgument('target_catalog')}")
-- MAGIC print(f"> Target database: {getArgument('target_database')}")

-- COMMAND ----------

USE CATALOG ${target_catalog};
USE SCHEMA ${target_database};

-- COMMAND ----------

CREATE OR REPLACE TABLE customer_silver
AS
SELECT customer_id, 
       customer_name, 
       customer_email, 
       store_code
FROM customer_bronze;

-- COMMAND ----------

CREATE OR REPLACE TABLE sales_silver
AS
SELECT int(StoreCode) AS store_code,
       int(ProductCode) AS product_code,
       StoreGroup AS store_group,
       ProductGroup AS product_group,
       double(SalesAmount) AS transaction_amount,
       date(TransactionDate) AS transaction_date,
       inserted_at,
       file_path
FROM sales_bronze

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import pyspark.sql.functions as F
-- MAGIC import pyspark.sql.types as T
-- MAGIC import json
-- MAGIC
-- MAGIC def cast_string_to_array(x):
-- MAGIC     res = json.loads(x)
-- MAGIC     return res
-- MAGIC   
-- MAGIC cast_coord = F.udf(cast_string_to_array, T.ArrayType(T.StringType()))

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df = spark.sql("select * from store_bronze")
-- MAGIC df = df.withColumn("store_coord_new", cast_coord(F.col("store_coordinates")))
-- MAGIC df.createOrReplaceTempView("store_temp")
-- MAGIC display(df)

-- COMMAND ----------

CREATE OR REPLACE TABLE store_silver
AS
SELECT store_id,
       store_name,
       store_phone,
       store_address,
       double(store_coord_new[0]) AS store_lat,
       double(store_coord_new[1]) AS store_long,
       inserted_at,
       file_path
FROM store_temp
