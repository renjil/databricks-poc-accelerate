# Databricks notebook source
# MAGIC %md
# MAGIC # `data_cleanup`

# COMMAND ----------
dbutils.widgets.text("target_catalog", "poc_accelerate_default_catalog")
# COMMAND ----------
# DBTITLE 1,Module Imports
from src.utils.common import Schema
from src.utils.notebook_utils import load_and_set_env_vars

# COMMAND ----------
# DBTITLE 1,Load Config
# Load env vars from config file (`conf/env_name/` dir)
env_vars = load_and_set_env_vars()

# COMMAND ----------
property_schema = Schema(
    catalog=dbutils.widgets.get("target_catalog"), schema=env_vars["property_schema"]
)

spark.sql(f"DROP SCHEMA IF EXISTS {property_schema.qualified_name} CASCADE")
