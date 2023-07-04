try:
    from pyspark.sql import SparkSession

    spark = SparkSession.builder.getOrCreate()

except Exception as e:
    from databricks.connect import DatabricksSession
    from databricks.sdk.core import Config

    config = Config(profile="aws-e2-demo")
    spark = DatabricksSession.builder.sdkConfig(config).getOrCreate()
