from typing import Dict
from abc import ABC, abstractmethod
import pandas as pd
from sklearn.metrics import roc_auc_score, r2_score, f1_score, accuracy_score, mean_squared_error, mean_absolute_error


class Evaluation(ABC):
    """
    Abstract class for computing evaluation metrics for a model.
    """

    @abstractmethod
    def evaluate(y_true: pd.Series, y_score: pd.Series, metric_prefix: str = "") -> Dict:
        """
        Parameters
        ----------
        y_true : array-like of shape (n_samples,) or (n_samples, n_classes)
            True labels or binary label indicators
        y_score : array-like of shape (n_samples,) or (n_samples, n_classes)
            Target scores.
        metric_prefix : str
            Prefix for each metric key in the returned dictionary

        Returns
        -------
        Dictionary of (metric name, computed value)
        """
        pass


class RegressionEvaluation(Evaluation):
    """
    Class for computing evaluation metrics for a regression model.
    """

    @staticmethod
    def evaluate(y_true: pd.Series, y_score: pd.Series, metric_prefix: str = "") -> Dict:
        """
        Parameters
        ----------
        y_true : array-like of shape (n_samples,) or (n_samples, n_classes)
            True labels or binary label indicators
        y_score : array-like of shape (n_samples,) or (n_samples, n_classes)
            Target scores.
        metric_prefix : str
            Prefix for each metric key in the returned dictionary

        Returns
        -------
        Dictionary of (metric name, computed value)
        """

        return {
            f"{metric_prefix}r2_score": r2_score(y_true, y_score),
            f"{metric_prefix}root_mean_squared_error": mean_squared_error(y_true, y_score, squared=False),
            f"{metric_prefix}mean_squared_error": mean_squared_error(y_true, y_score, squared=True),
            f"{metric_prefix}mean_absolute_error": mean_absolute_error(y_true, y_score),
        }


class ClassificationEvaluation(Evaluation):
    @staticmethod
    def evaluate(y_true: pd.DataFrame, y_score: pd.DataFrame, metric_prefix: str = "") -> Dict:
        """
        Evaluate model performance on validation data.

        Returns
        -------
        Dictionary of (metric name, computed value)
        """
        return {
            # TODO: Add roc_auc_score for multiclass
            # This requires some changes to model_train by enforcing the use of the predict_proba method
            # when we want to have the roc_auc_score. To keep model_train pipeline generic (for
            # regression and classification) we would need to add a flag to the pipeline config to
            # indicate whether to use predict or predict_proba for the evaluation step.
            # /Code -->
            # f"{metric_prefix}roc_auc_score": roc_auc_score(
            #     y_true=y_true, y_score=y_score, average="weighted", multi_class="ovo"
            # ),
            # <-- Code/
            f"{metric_prefix}f1_score": f1_score(y_true, y_score, average="weighted"),
            f"{metric_prefix}accuracy_score": accuracy_score(y_true, y_score),
        }


if __name__ == "__main__":
    print("ModelEvaluation")
    print(RegressionEvaluation().evaluate(pd.Series([1, 2, 3]), pd.Series([1, 2, 3])))
    print(RegressionEvaluation().evaluate(pd.Series([1, 2, 3]), pd.Series([1, 2, 3]), "test_"))
