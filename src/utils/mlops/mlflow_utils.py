from dataclasses import dataclass


@dataclass
class MLflowTrackingConfig:
    """
    Configuration data class used to unpack MLflow parameters during a model training run.

    Attributes:
        run_name (str)
            Name of MLflow run
        experiment_id (int)
            ID of the MLflow experiment to be activated. If an experiment with this ID does not exist, raise an exception.
        experiment_path (str)
            Case sensitive name of the experiment to be activated. If an experiment with this name does not exist,
            a new experiment wth this name is created.
        model_name (str)
            Name of the registered model under which to create a new model version. If a registered model with the given
            name does not exist, it will be created automatically.
    """

    run_name: str
    experiment_id: int = None
    experiment_path: str = None
    model_name: str = None


if __name__ == "__main__":
    mlflow_tracking_config = MLflowTrackingConfig(
        run_name="example run",
        experiment_id=1,
        experiment_path="example path",
        model_name="example model",
    )
    print("\n obj:", mlflow_tracking_config)
    print("\n obj.run_name: '" + mlflow_tracking_config.run_name + "'")
    print("\n obj.experiment_id: '" + str(mlflow_tracking_config.experiment_id) + "'")
    print("\n obj.experiment_path: '" + mlflow_tracking_config.experiment_path + "'")
    print("\n obj.model_name: '" + mlflow_tracking_config.model_name + "'")

    # print(mlflow_tracking_config.experiment_id, "\n")
    # print(mlflow_tracking_config.experiment_path, "\n")
    # print(mlflow_tracking_config.model_name, "\n")
    print("\n")
