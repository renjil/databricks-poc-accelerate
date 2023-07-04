# Databricks notebook source
# MAGIC %md
# MAGIC # Property Value Model Training
# MAGIC Pipeline to execute model training. Params, metrics and model artifacts will be tracked to MLflow Tracking.
# MAGIC Optionally, the resulting model will be registered to MLflow Model Registry if provided.
# MAGIC <div>
# MAGIC <img src="https://images.unsplash.com/photo-1516156008625-3a9d6067fab5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80" width="500"/>
# MAGIC </div>

# COMMAND ----------
dbutils.widgets.text("target_catalog", "poc_accelerate_abc_catalog")
dbutils.widgets.text("project_name", "poc_accelerate_abc")
dbutils.widgets.text("num_estimators", "")
# COMMAND ----------
# MAGIC %md
# MAGIC ## Module Imports

# COMMAND ----------
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.compose import make_column_selector as selector, ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from pprint import pprint

from coolname import generate_slug

from src.utils.common import Table
from src.utils.notebook_utils import load_and_set_env_vars, load_config
from src.utils.mlops.model_train import (
    ModelTrain,
    ModelTrainConfig,
)
from src.utils.mlops.evaluation_utils import RegressionEvaluation
from src.utils.mlops.plot_utils import PlotGenerator
from src.utils.mlops.mlflow_utils import MLflowTrackingConfig

# COMMAND ----------
# MAGIC %md
# MAGIC ## Load Config Params

# COMMAND ----------
# Load pipeline config from config file (`conf/pipeline_config/` dir)
pipeline_config = load_config(
    config_name="propval_model_train_cfg",
)
# For demo purposes so we can change the number of estimators in the notebook (and in workflows)
if dbutils.widgets.get("num_estimators") != "":
    pipeline_config["model_params"]["n_estimators"] = int(
        dbutils.widgets.get("num_estimators")
    )
pprint(pipeline_config)

# COMMAND ----------
# MAGIC %md
# MAGIC ## Define Model Pipeline


# COMMAND ----------
def simple_rf_regressor(model_params: dict) -> Pipeline:
    """
    Returns a model training pipeline for training random forest regressor.
    """
    numeric_transformer = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
        ]
    )

    categorical_transformer = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="constant", fill_value="missing")),
            ("onehot", OneHotEncoder(handle_unknown="ignore")),
        ]
    )

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", numeric_transformer, selector(dtype_exclude="object")),
            ("cat", categorical_transformer, selector(dtype_include="object")),
        ],
        remainder="passthrough",
        sparse_threshold=0,
    )

    rf_regressor = RandomForestRegressor(**model_params)

    pipeline = Pipeline(
        [
            ("preprocessor", preprocessor),
            ("regressor", rf_regressor),
        ]
    )
    return pipeline


# COMMAND ----------
# MAGIC %md
# MAGIC ## Build Pipeline Config Components

# COMMAND ----------
# Instantiate model pipeline
model_pipeline = simple_rf_regressor(model_params=pipeline_config["model_params"])

# Instantiate model evaluation
model_evaluation = RegressionEvaluation()

# Instantiate MLflow Tracking config
run_name = f"{pipeline_config['mlflow_params']['run_name']}_{generate_slug(2)}"
experiment_path = f"/Shared/{dbutils.widgets.get('project_name')}/{dbutils.widgets.get('project_name')}_{pipeline_config['mlflow_params']['experiment_name']}"
model_name = f"{dbutils.widgets.get('project_name')}_{pipeline_config['mlflow_params']['model_name']}"
mlflow_tracking_cfg = MLflowTrackingConfig(
    run_name=run_name,
    experiment_path=experiment_path,
    model_name=model_name,
)

# Instantiate ModelTrainConfig for ModelTrain pipeline
model_train_cfg = ModelTrainConfig(
    mlflow_tracking_cfg=mlflow_tracking_cfg,
    train_table=Table(
        dbutils.widgets.get("target_catalog"),
        pipeline_config["data_input"]["training_set"]["schema"],
        pipeline_config["data_input"]["training_set"]["table"],
    ),
    label_col=pipeline_config["data_input"]["label_col"],
    model_pipeline=model_pipeline,
    model_params=pipeline_config["model_params"],  # For logging with model
    preproc_params=pipeline_config["preproc_params"],
    model_evaluation=model_evaluation,
    plot_generator=None,
    conf=pipeline_config,
    env_vars=None,
)

# COMMAND ----------
# MAGIC %md
# MAGIC ## Execute Pipeline

# COMMAND ----------
# Initialise ModelTrain Pipeline with ModelTrainConfig
model_train = ModelTrain(cfg=model_train_cfg)
# Execute pipeline
model_train.run()
