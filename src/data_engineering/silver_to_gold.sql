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

-- total revenue
CREATE OR REPLACE TABLE total_revenue_gold
AS
SELECT SUM(transaction_amount) as total_amount FROM sales_silver;

-- COMMAND ----------

-- stores with most customers
CREATE OR REPLACE TABLE top_store_traffic_gold
AS
WITH top_stores
AS
(SELECT store_code, 
        count(customer_id) AS customer_count
FROM customer_silver cs
GROUP BY store_code
ORDER BY customer_count DESC)

SELECT ss.store_name, 
       ts.customer_count
FROM top_stores ts
LEFT JOIN store_silver ss ON ts.store_code = ss.store_id

-- COMMAND ----------

-- total transaction amount per store
CREATE OR REPLACE TABLE store_txn_amount_gold
AS
SELECT store_code, 
       sum(transaction_amount) AS total_amount
FROM sales_silver
GROUP BY store_code
ORDER BY total_amount DESC

-- COMMAND ----------

-- total transaction amount per product group
CREATE OR REPLACE TABLE product_group_txn_amount_gold
AS
SELECT product_group, 
       sum(transaction_amount) AS total_amount
FROM sales_silver
GROUP BY product_group
ORDER BY total_amount DESC
