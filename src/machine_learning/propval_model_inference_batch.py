# Databricks notebook source
# MAGIC %md
# MAGIC # Property Value Model Inference
# MAGIC Pipeline to execute model inference. Model will be loaded from MLflow Model Registry and used to make predictions on a holdout dataset.
# MAGIC <div>
# MAGIC <img src="https://www.wealthmanagement.com/sites/wealthmanagement.com/files/styles/article_featured_retina/public/usa-homes-sales.jpg?itok=UGNandcY" width="500"/>
# MAGIC </div>

# COMMAND ----------
dbutils.widgets.text("target_catalog", "poc_accelerate_abc_catalog")
dbutils.widgets.text("project_name", "poc_accelerate_abc")
# COMMAND ----------
# MAGIC %md
# MAGIC ## Module Imports

# COMMAND ----------
from src.utils.common import Table
from src.utils.notebook_utils import load_config, load_and_set_env_vars
from src.utils.mlops.model_inference_batch import ModelInferenceBatchPipeline
from pprint import pprint

# COMMAND ----------
# MAGIC %md
# MAGIC ## Load Config Params

# COMMAND ----------
# Load pipeline config from config file (`conf/pipeline_config/` dir)
pipeline_config = load_config(
    config_name="propval_model_inference_batch_cfg",
)
pprint(pipeline_config)
# COMMAND ----------
# MAGIC %md
# MAGIC ## Build Pipeline Config Components
# COMMAND ----------
# Configure model URI
model_name = f"{dbutils.widgets.get('project_name')}_{pipeline_config['mlflow_params']['model_name']}"
model_registry_stage = pipeline_config["mlflow_params"]["model_registry_stage"]
model_uri = f"models:/{model_name}/{model_registry_stage}"

# Configure input and output tables
input_table = Table(
    catalog=dbutils.widgets.get("target_catalog"),
    schema=pipeline_config["data_input"]["schema"],
    table=pipeline_config["data_input"]["table"],
)
output_table = Table(
    catalog=dbutils.widgets.get("target_catalog"),
    schema=pipeline_config["data_output"]["schema"],
    table=pipeline_config["data_output"]["table"],
)

# COMMAND ----------
# MAGIC %md
# MAGIC ## Execute Pipeline

# COMMAND ----------
# Initialise ModelInferenceBatchPipeline with config components
cali_housing_inference_pipeline = ModelInferenceBatchPipeline(
    model_uri=model_uri,
    input_table=input_table,
    output_table=output_table,
)
# Execute pipeline
cali_housing_inference_pipeline.run_and_write_batch()
