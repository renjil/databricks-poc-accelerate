import pyspark.sql.dataframe
from pyspark.sql.functions import col, struct, lit
import mlflow
from mlflow import MlflowClient

from src.utils.get_spark import spark
from src.utils.logger_utils import get_logger
from src.utils.common import Table

_logger = get_logger()


class ModelInferenceBatchPipeline:
    """
    Class to execute model inference.
    Apply the model at the specified URI for batch inference on the table with name input_table_name,
    writing results to the table with name output_table_name
    """

    def __init__(
        self,
        model_uri: str,
        input_table: Table,
        output_table: Table = None,
    ):
        """
        Parameters
        ----------
        model_uri : str
            MLflow model uri. Model model must have been logged using the Feature Store API.
        input_table : Table
            Table to load as a Spark DataFrame to score the model on.
        output_table : str
            Output table to write results to.
        """
        self.model_uri = model_uri
        self.input_table = input_table
        self.output_table = output_table

    def _load_input_table(self) -> pyspark.sql.DataFrame:
        """
        Load Spark DataFrame containing data for training

        Returns
        -------
        pyspark.sql.DataFrame
        """
        return spark.table(self.input_table.qualified_name)

    def _get_model_version(self) -> int:
        """
        Get model version from MLflow Model Registry

        Returns
        -------
        int
            Model version
        """
        url = self.model_uri
        if url.startswith("models:/") and url.split("models:/")[1].split("/")[1] in [
            "",
            "archive",
            "staging",
            "production",
        ]:
            model_name = url.split("models:/")[1].split("/")[0]
            model_stage = url.split("models:/")[1].split("/")[1]

        else:
            raise ValueError(
                f"Invalid URL format. Must be models:/<model_name>/<model_stage>. Your URL: {url}"
            )

        client = MlflowClient()
        version = client.get_latest_versions(name=model_name, stages=[model_stage])[0]
        _logger.info(f"Using model version: {version}")
        return version.version

    def score_batch(self, df: pyspark.sql.DataFrame) -> pyspark.sql.DataFrame:
        """
        Load and apply model from MLflow Model Registry to Spark DataFrame.

        Parameters
        ----------
        df : pyspark.sql.DataFrame
            Spark DataFrame to apply model to.

        Returns
        -------
        pyspark.sql.DataFrame
            Spark DataFrame with predictions column added.
        """
        loaded_model = mlflow.pyfunc.spark_udf(
            spark, model_uri=self.model_uri, result_type="double"
        )
        # loaded_model = mlflow.pyfunc.spark_udf(spark, model_uri=self.model_uri, result_type="double", env_manager="conda")
        return df.withColumn(
            "prediction", loaded_model(struct([col(c) for c in df.columns]))
        )

    def run_batch(self) -> pyspark.sql.DataFrame:
        """
        Load input table, apply model, and write output table.
        """
        input_df = self._load_input_table()
        output_df = self.score_batch(input_df)
        return output_df

    def run_and_write_batch(self, mode: str = "overwrite") -> None:
        """
        Run batch inference, save as output table.

        Parameters
        ----------
        mode : str
            Spark write mode. Defaults to "overwrite". Specifies behaviour when predictions already exist.
                    Options include:
                        - "append": Append new predictions to existing predictions
                        - "overwrite": Overwrite existing predictions

        Returns
        -------
        None

        """
        _logger.info("==========Running batch model inference==========")
        pred_df = self.run_batch().withColumn(
            "model_details",
            struct(
                lit(self.model_uri).alias("model_uri"),
            ),
        )

        _logger.info("==========Writing predictions to output table==========")
        _logger.info(f"mode={mode}")

        _logger.info(f"Predictions written to {self.output_table.qualified_name} table")
        pred_df.write.format("delta").mode(mode).option(
            "mergeSchema", True
        ).saveAsTable(self.output_table.qualified_name)

        _logger.info("==========Batch model inference completed==========")
