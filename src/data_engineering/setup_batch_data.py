# Databricks notebook source
dbutils.widgets.text("location", "")
dbutils.widgets.text("target_catalog", "")
dbutils.widgets.text("target_database", "")

# COMMAND ----------

pip install faker

# COMMAND ----------

import numpy as np
import pandas as pd

from faker import Faker
from random import shuffle
from pyspark.sql.functions import to_date

# COMMAND ----------

# generate sales data
def generate_sales_csv():
  store_codes = np.arange(1,10)
  product_codes = np.arange(1,101)
  date_range = pd.date_range(start = "2019-01-01", end = "2020-12-31", freq="D")

  # generate a cartesian product of the date_range, store_codes, and product_codes arrays
  index = pd.MultiIndex.from_product(
    [date_range, store_codes, product_codes],
    names = ["Date", "StoreCode", "ProductCode"]
  )
  sales = pd.DataFrame(index = index)
  sales.reset_index(inplace=True)
  
  store_groups = ["Small","Medium","Large"]*3
  shuffle(store_groups)
  stores = pd.DataFrame({
    "StoreCode": np.arange(1,10),
    "StoreGroup": store_groups
  })

  product_groups = ["Electronics","Apparel","Books","Specialty"] * 25
  shuffle(product_groups)
  products = pd.DataFrame({
    "ProductCode": np.arange(1,101),
    "ProductGroup": product_groups
  })

  # merge store and product to sales df
  sales = pd.merge(sales, stores, on="StoreCode", how="left")
  sales = pd.merge(sales, products, on="ProductCode", how="left")

  # add amount
  size = len(sales)
  sales_amount = np.random.randint(0, 100, size=len(sales))
  sales["SalesAmount"] = sales_amount

  # convert to spark dataframe
  sales_df = spark.createDataFrame(sales)
  # format date
  sales_df = sales_df.withColumn("TransactionDate", to_date(sales_df.Date)).drop(sales_df.Date)

  # write as csv
  output_path = f"{getArgument('location')}/sales"
  sales_df.coalesce(1).write.mode('overwrite').option('header', 'true').csv(output_path)  
  return output_path

# COMMAND ----------

# generate customer data
def generate_fake_customers(num):

    fake = Faker("en_AU")
    
    # lists to randomly assign to workers
    store_codes = np.arange(1,10) 

    fake_customers = [{'customer_id': x,
                  'store_code':np.random.choice(store_codes),
                  'customer_name':fake.name(), 
                  'customer_email':fake.email(),
                  'customer_phone':fake.phone_number(),
                  'customer_credit_card': fake.credit_card_full().replace("\n","")} for x in range(num)]
    
    return fake_customers
        
def generate_customer_json():
    cust_pdf = pd.DataFrame(generate_fake_customers(num=5000))
    # convert to spark dataframe
    cust_df = spark.createDataFrame(cust_pdf)
    # write as json
    output_path = f"{getArgument('location')}/customer"
    cust_df.coalesce(1).write.mode('overwrite').json(output_path)  
    return output_path

# COMMAND ----------

# generate store data
def generate_fake_stores():

    fake = Faker("en_US")

    fake_stores = [{'store_id': x+1,
                  'store_name': f"{fake.city()} store",
                  'store_address':fake.address().replace("\n", " "),
                  'store_phone':fake.phone_number(),
                  'store_coordinates': fake.location_on_land()} for x in range(10)]
    
    return fake_stores
        
def generate_store_json():
    store_pdf = pd.DataFrame(generate_fake_stores())
    # convert to spark dataframe
    store_df = spark.createDataFrame(store_pdf)
    # write as json
    output_path = f"{getArgument('location')}/store"
    store_df.coalesce(1).write.mode('overwrite').json(output_path)  

    return output_path


# COMMAND ----------

# Generate data sets for sales, customer and store
sales_csv = generate_sales_csv()
customer_json = generate_customer_json()
store_json = generate_store_json()

# COMMAND ----------

# Return to the caller, passing the variables needed for file paths and database

response = {"sales": sales_csv,"customer": customer_json, "store": store_json}

# dbutils.notebook.exit(response)

# COMMAND ----------

# MAGIC %sql
# MAGIC -- setup catalog and schema for medallion pipeline
# MAGIC CREATE CATALOG IF NOT EXISTS ${target_catalog};
# MAGIC CREATE SCHEMA IF NOT EXISTS ${target_catalog}.${target_database};

# COMMAND ----------

# MAGIC %sql
# MAGIC -- verify database created
# MAGIC DESCRIBE DATABASE ${target_catalog}.${target_database};

# COMMAND ----------


