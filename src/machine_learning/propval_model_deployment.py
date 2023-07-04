# Databricks notebook source
# MAGIC %md
# MAGIC # Property Value Model Deployment
# MAGIC Pipeline to execute model deployment. Model will be loaded from MLflow Model Registry and deployed.
# MAGIC <div>
# MAGIC <img src="https://www.wealthmanagement.com/sites/wealthmanagement.com/files/styles/article_featured_retina/public/usa-homes-sales.jpg?itok=UGNandcY" width="500"/>
# MAGIC </div>

# COMMAND ----------
dbutils.widgets.text("target_catalog", "poc_accelerate_abc_catalog")
dbutils.widgets.text("project_name", "poc_accelerate_abc")
dbutils.widgets.dropdown(
    "compare_stag_v_prod",
    "False",
    ["False", "True"],
    "Compare Staging vs Production Model",
)

# COMMAND ----------
# MAGIC %md
# MAGIC ## Module Imports

# COMMAND ----------
from src.utils.common import Table
from src.utils.notebook_utils import load_and_set_env_vars, load_config
from src.utils.mlops.model_deployment import (
    ModelDeployment,
    ModelDeploymentConfig,
)
from src.utils.mlops.evaluation_utils import RegressionEvaluation
from src.utils.mlops.mlflow_utils import MLflowTrackingConfig
from pprint import pprint

# COMMAND ----------
# MAGIC %md
# MAGIC ## Load Config Params

# COMMAND ----------
# Load pipeline specific config from config file (`conf/pipeline_config/` dir)
pipeline_config = load_config(config_name="propval_model_deployment_cfg")
pprint(pipeline_config)
# COMMAND ----------
# MAGIC %md
# MAGIC ## Build Pipeline Config Components

# COMMAND ----------
# Build MLflow Tracking config
experiment_path = f"/Shared/{dbutils.widgets.get('project_name')}/{dbutils.widgets.get('project_name')}_{pipeline_config['mlflow_params']['experiment_name']}"
model_name = f"{dbutils.widgets.get('project_name')}_{pipeline_config['mlflow_params']['model_name']}"
mlflow_tracking_cfg = MLflowTrackingConfig(
    run_name="staging_vs_prod_comparison",
    experiment_path=experiment_path,
    model_name=model_name,
)

# Build ModelDeploymentConfig for ModelDeployment pipeline
model_deployment_cfg = ModelDeploymentConfig(
    mlflow_tracking_cfg=mlflow_tracking_cfg,
    reference_data=Table(
        catalog=dbutils.widgets.get("target_catalog"),
        schema=pipeline_config["data_input"]["reference_set"]["schema"],
        table=pipeline_config["data_input"]["reference_set"]["table"],
    ),
    label_col=pipeline_config["data_input"]["label_col"],
    model_evaluation=RegressionEvaluation(),
    comparison_metric=pipeline_config["model_comparison_params"]["metric"],
    higher_is_better=pipeline_config["model_comparison_params"]["higher_is_better"],
)

# COMMAND ----------
# MAGIC %md
# MAGIC ## Execute Pipeline

# COMMAND ----------
# Initialise ModelDeployment with ModelDeploymentConfig
model_deployment = ModelDeployment(cfg=model_deployment_cfg)
if dbutils.widgets.get("compare_stag_v_prod").lower() == "true":
    # Execute pipeline comparing staging and production models
    model_deployment.run()
else:
    # Execute pipeline without comparing staging vs production model
    model_deployment.run_wo_comparison()
