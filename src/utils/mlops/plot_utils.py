from typing import List

import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import seaborn as sns


class PlotGenerator:
    """
    Class to generate plots for model evaluation.
    """

    def __init__(self, model_type: str) -> None:
        """
        Parameters
        ----------
        model_type : str
            Type of model to evaluate. Supported model types are "multiclass_classification" and "regression".
        """
        self.model_type = model_type

    def _plot_regression_residuals(self, y_true: pd.Series, y_score: pd.Series, filename_prefix: str = "") -> str:
        """ """
        df = pd.DataFrame({"y_true": y_true, "y_score": y_score})
        df["residuals"] = df["y_true"] - df["y_score"]
        df.plot(x="y_true", y="residuals", kind="scatter")
        plt.xlabel("Observation")
        plt.ylabel("Residual")
        plt.title("Residuals")

        file_name = f"{filename_prefix}residuals.png"
        plt.savefig(file_name)
        plt.close()
        return file_name

    def _plot_regression_predictions(self, y_true: pd.Series, y_score: pd.Series, filename_prefix: str = "") -> str:
        """ """
        df = pd.DataFrame({"y_true": y_true, "y_score": y_score})
        df.plot(x="y_true", y="y_score", kind="scatter")
        plt.xlabel("Observation")
        plt.ylabel("Prediction")
        plt.title("Predictions")

        file_name = f"{filename_prefix}predictions"
        plt.savefig(file_name, format="png")
        plt.close()
        return file_name

    def _plot_multiclass_classification_confusion_matrix(
        self, y_true: pd.Series, y_score: pd.Series, filename_prefix: str = ""
    ) -> str:
        """ """
        cm = confusion_matrix(y_true=y_true, y_pred=y_score)
        df_cm = pd.DataFrame(cm, index=range(cm.shape[0]), columns=range(cm.shape[1]))
        plt.figure(figsize=(10, 7))
        sns.heatmap(df_cm, annot=True, cmap="Blues", fmt="g")
        plt.xlabel("Predicted")
        plt.ylabel("Actual")
        plt.title("Confusion Matrix")

        file_name = f"{filename_prefix}confusion_matrix.png"
        plt.savefig(file_name)
        plt.close()
        return file_name

    def run(self, y_true: pd.Series, y_score: pd.Series, filename_prefix: str = "") -> List[str]:
        if self.model_type == "multiclass_classification":
            return [self._plot_multiclass_classification_confusion_matrix(y_true, y_score, filename_prefix)]

        elif self.model_type == "regression":
            return [
                self._plot_regression_residuals(y_true, y_score, filename_prefix),
                self._plot_regression_predictions(y_true, y_score, filename_prefix),
            ]
        else:
            raise ValueError(
                f"Unsupported model type: {self.model_type}, choose from 'multiclass_classification' or 'regression'"
            )  # TODO keep this error message in sync with the one in evaluation_utils.py
