# Databricks notebook source
# MAGIC %md
# MAGIC # `setup_data`
# MAGIC Pipeline to setup data that we will use for our ML experiment.

# COMMAND ----------
dbutils.widgets.text("target_catalog", "poc_accelerate_default_catalog")
# COMMAND ----------
# DBTITLE 1,Module Imports
from src.utils.common import Table, Schema
from src.utils.fetch_sklearn_datasets import fetch_sklearn_cali_housing
from src.utils.notebook_utils import load_config

# COMMAND ----------
# Dev imports
from src.utils.logger_utils import get_logger
from src.utils.get_spark import spark

_logger = get_logger()

# COMMAND ----------
# DBTITLE 1,Load Config
pipeline_config = load_config(config_name="data_setup_cfg")

# COMMAND ----------
# DBTITLE 1,Set Variables
holdout_pct = 20
random_seed = 42

property_schema = Schema(
    catalog=dbutils.widgets.get("target_catalog"),
    schema=pipeline_config["data_output"]["schema"],
)
print(property_schema.qualified_name)

# COMMAND ----------
# DBTITLE 1,Create Catalogs
spark.sql(f"CREATE CATALOG IF NOT EXISTS {property_schema.catalog}")

# COMMAND ----------
# DBTITLE 1,Create Schemas
spark.sql(f"CREATE SCHEMA IF NOT EXISTS {property_schema.qualified_name}")


# COMMAND ----------
def setup_data(fn, schema: Schema) -> None:
    """
    Setup data for ML experiment.

    Args:
        fn: Function that returns a Spark DataFrame of data.
        schema: Schema object that contains catalog and schema name.

    Returns:
        None
    """
    # Create reference to tables
    train_table = Table.from_string(schema.qualified_name + ".training_set")
    holdout_table = Table.from_string(schema.qualified_name + ".holdout_set")

    # Create dataframe from provided function
    df = fn()

    # Separate holdout set
    holdout_decimal = holdout_pct / 100
    train_df, holdout_df = df.randomSplit(
        [(1 - holdout_decimal), holdout_decimal], seed=random_seed
    )

    # Write to metastore
    train_df.write.mode("overwrite").format("delta").saveAsTable(
        train_table.qualified_name
    )
    holdout_df.write.mode("overwrite").format("delta").saveAsTable(
        holdout_table.qualified_name
    )


setup_data(fetch_sklearn_cali_housing, property_schema)
