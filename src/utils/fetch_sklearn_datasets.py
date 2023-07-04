import pyspark.sql.dataframe
from sklearn.datasets import fetch_california_housing, load_iris, load_wine
import pandas as pd
import re

from src.utils.get_spark import spark


def clean_column_names(df: pyspark.sql.DataFrame) -> pyspark.sql.DataFrame:
    """
    Clean column names
    """
    return df.toDF(*(re.sub("[ ,;{}()\n\t=]", "_", c) for c in df.columns))


def clean_column_names_pandas(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean column names
    """
    return df.rename(columns={c: re.sub("[ ,;{}()\n\t=]", "_", c) for c in df.columns})


def fetch_sklearn_cali_housing() -> pyspark.sql.DataFrame:
    df: pd.DataFrame = fetch_california_housing(as_frame=True).frame
    df = clean_column_names_pandas(df)
    return spark.createDataFrame(df)


def fetch_sklearn_iris() -> pyspark.sql.DataFrame:
    df: pd.DataFrame = load_iris(as_frame=True).frame
    df = clean_column_names_pandas(df)
    return spark.createDataFrame(df)


def fetch_sklearn_wine() -> pyspark.sql.DataFrame:
    df: pd.DataFrame = load_wine(as_frame=True).frame
    df = clean_column_names_pandas(df)
    return spark.createDataFrame(df)
