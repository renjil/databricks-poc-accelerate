from dataclasses import dataclass
from typing import Dict, Any
import pprint

import pyspark.sql.dataframe
import sklearn
from sklearn.model_selection import train_test_split
import pandas as pd
import mlflow
from mlflow.models import infer_signature
from mlflow.tracking import MlflowClient

from src.utils.common import Table
from src.utils.logger_utils import get_logger
from src.utils.get_spark import spark
from src.utils.mlops.mlflow_utils import MLflowTrackingConfig
from src.utils.mlops.evaluation_utils import Evaluation
from src.utils.mlops.plot_utils import PlotGenerator

_logger = get_logger()


@dataclass
class ModelTrainConfig:
    """
    Configuration data class used to execute ModelTrain pipeline.

    Attributes:
        mlflow_tracking_cfg (MLflowTrackingConfig)
            Configuration data class used to unpack MLflow parameters during a model training run.
        model_pipeline (sklearn.pipeline.Pipeline):
            Pipeline to use for model training.
        model_params (dict):
            Dictionary of params for model.
        preproc_params (dict):
            Params to use in preprocessing pipeline. Read from model_train.yml
            - test_size: Proportion of input data to use as training data
            - random_state: Random state to enable reproducible train-test split
        conf (dict):
            [Optional] dictionary of conf file used to trigger pipeline. If provided will be tracked as a yml
            file to MLflow tracking.
        env_vars (dict):
            [Optional] dictionary of environment variables to trigger pipeline. If provided will be tracked as a yml
            file to MLflow tracking.

        TODO: keep up to date
    """

    mlflow_tracking_cfg: MLflowTrackingConfig
    train_table: Table
    label_col: str
    model_pipeline: sklearn.pipeline.Pipeline
    model_params: Dict[str, Any]
    preproc_params: Dict[str, Any]
    model_evaluation: Evaluation = None
    plot_generator: PlotGenerator = None
    conf: Dict[str, Any] = None
    env_vars: Dict[str, str] = None


class ModelTrain:
    """
    TODO: check docstrings
    Class to train a model on a given dataset and log results to MLflow.

    Attributes:
        cfg (ModelTrainConfig):
            Configuration data class used to execute ModelTrain pipeline.

    Methods:
        run():
            Execute ModelTrain pipeline.
    """

    def __init__(self, cfg: ModelTrainConfig):
        self.cfg = cfg

    @staticmethod
    def _set_experiment(mlflow_tracking_cfg: MLflowTrackingConfig):
        """
        Set MLflow experiment. Use one of either experiment_id or experiment_path
        """
        if mlflow_tracking_cfg.experiment_id is not None:
            _logger.info(f"MLflow experiment_id: {mlflow_tracking_cfg.experiment_id}")
            mlflow.set_experiment(experiment_id=mlflow_tracking_cfg.experiment_id)
        elif mlflow_tracking_cfg.experiment_path is not None:
            _logger.info(
                f"MLflow experiment_path: {mlflow_tracking_cfg.experiment_path}"
            )
            mlflow.set_experiment(experiment_name=mlflow_tracking_cfg.experiment_path)
        else:
            raise RuntimeError(
                "MLflow experiment_id or experiment_path must be set in mlflow_params"
            )

    def _transition_staging_models_to_none(self, client: MlflowClient):
        """Because we create a new staging model for each run, if things are run out of
        order, sometimes you can end up with multiple staging models. This function
        transitions all staging models to None so that we can create a new staging model
        """
        model_name = self.cfg.mlflow_tracking_cfg.model_name
        staging_models = client.get_latest_versions(name=model_name, stages=["staging"])
        if len(staging_models) > 0:
            _logger.info(
                'Transition candidate model from stage="staging" to stage="archived"'
            )
            for model in staging_models:
                client.transition_model_version_stage(
                    name=model_name, version=model.version, stage="archived"
                )

    def create_train_test_split(self, df: pyspark.sql.dataframe.DataFrame):
        """
        Create train-test split of data
        """
        label_col = self.cfg.label_col
        X = df.drop(label_col, axis=1)
        y = df[label_col]
        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=self.cfg.preproc_params["test_size"],
            random_state=self.cfg.preproc_params["random_state"],
        )
        return X_train, X_test, y_train, y_test

    def fit_pipeline(
        self, X_train: pd.DataFrame, y_train: pd.Series
    ) -> sklearn.pipeline.Pipeline:
        """
        Create sklearn pipeline and fit pipeline.

        Parameters
        ----------
        X_train : pd.DataFrame
            Training data

        y_train : pd.Series
            Training labels

        Returns
        -------
        scikit-learn pipeline with fitted steps.
        """

        _logger.info("Fitting model_pipeline...")
        _logger.info(f"Model params: {pprint.pformat(self.cfg.model_params)}")
        model = self.cfg.model_pipeline.fit(X_train, y_train)

        return model

    def run(self):
        """
        Run ModelTrain pipeline. TODO: Add more details
        """

        _logger.info("Setting MLflow experiment...")
        mlflow_tracking_cfg: MLflowTrackingConfig = self.cfg.mlflow_tracking_cfg
        train_table: Table = self.cfg.train_table
        model_evaluation: Evaluation = self.cfg.model_evaluation

        self._set_experiment(mlflow_tracking_cfg)
        # mlflow.sklearn.autolog(log_input_examples=True, silent=True)

        _logger.info("Starting MLflow run...")
        with mlflow.start_run(run_name=mlflow_tracking_cfg.run_name) as run:
            _logger.info(f"MLflow run_id: {run.info.run_id}")

            # Log config files
            if self.cfg.conf is not None:
                mlflow.log_dict(self.cfg.conf, artifact_file="model_train_conf.yml")
            if self.cfg.env_vars is not None:
                mlflow.log_dict(
                    self.cfg.env_vars, artifact_file="model_train_env_vars.yml"
                )

            # Log model params
            mlflow.log_params(self.cfg.model_params)

            # Load data
            _logger.info(f"Loading data from table: '{train_table.qualified_name}'")
            data = spark.table(train_table.qualified_name).toPandas()

            # Create train-test split
            X_train, X_test, y_train, y_test = self.create_train_test_split(data)

            # Fit pipeline
            model = self.fit_pipeline(X_train, y_train)

            y_train_pred = pd.DataFrame(model.predict(X_train))
            y_test_pred = pd.DataFrame(model.predict(X_test))

            if model_evaluation:
                # Log train metrics
                eval_dict = model_evaluation.evaluate(
                    y_train, y_train_pred, metric_prefix="train_"
                )
                mlflow.log_metrics(eval_dict)

                # Log test metrics
                eval_dict = model_evaluation.evaluate(
                    y_test, y_test_pred, metric_prefix="test_"
                )
                mlflow.log_metrics(eval_dict)

            if self.cfg.plot_generator:
                # Log plots
                train_plots = self.cfg.plot_generator.run(
                    y_train, y_train_pred, filename_prefix="train_"
                )
                test_plots = self.cfg.plot_generator.run(
                    y_test, y_test_pred, filename_prefix="test_"
                )
                for plot in train_plots + test_plots:
                    mlflow.log_artifact(plot)

            # Log model
            mlflow.sklearn.log_model(
                model,
                artifact_path="model",
                input_example=X_train.iloc[:10],
                signature=infer_signature(X_train, y_train),
            )

            # Register model to MLflow Model Registry if provided
            if self.cfg.mlflow_tracking_cfg.model_name is not None:
                _logger.info(f"Registering model as: {mlflow_tracking_cfg.model_name}")
                model_details = mlflow.register_model(
                    f"runs:/{run.info.run_id}/model",
                    name=mlflow_tracking_cfg.model_name,
                )
                client = MlflowClient()
                model_version_details = client.get_model_version(
                    name=mlflow_tracking_cfg.model_name, version=model_details.version
                )

                # In case there is a model in staging, archive it
                self._transition_staging_models_to_none(client)

                _logger.info(
                    f"Transitioning model: {mlflow_tracking_cfg.model_name} to Staging"
                )
                client.transition_model_version_stage(
                    name=mlflow_tracking_cfg.model_name,
                    version=model_details.version,
                    stage="Staging",
                )
