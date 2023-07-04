from dataclasses import dataclass
from argparse import ArgumentParser
from typing import Dict, Any
from pyspark.sql import SparkSession
from logging import Logger

from src.utils.logger_utils import get_logger
from src.utils.get_spark import spark

_logger = get_logger()


def get_dbutils(
    spark: SparkSession,
):  # please note that this function is used in mocking by its name
    try:
        from pyspark.dbutils import DBUtils  # noqa

        if "dbutils" not in locals():
            utils = DBUtils(spark)
            return utils
        else:
            return locals().get("dbutils")
    except ImportError:
        return None


@dataclass(frozen=True)
class Table:
    catalog: str
    schema: str
    table: str

    @property
    def qualified_name(self):
        return f"{self.catalog}.{self.schema}.{self.table}"

    @property
    def name(self):
        return f"{self.schema}.{self.table}"

    @classmethod
    def from_string(cls, data: str) -> "Table":
        """
        Alternative constructor to initialise a TableReference object from a string.
        """
        cat, schema, table = data.split(".")
        return cls(cat, schema, table)


@dataclass(frozen=True)
class Schema:
    catalog: str
    schema: str

    @property
    def qualified_name(self):
        return f"{self.catalog}.{self.schema}"

    @property
    def name(self):
        return f"{self.schema}"

    @classmethod
    def from_string(cls, data: str) -> "Table":
        """
        Alternative constructor to initialise a TableReference object from a string.
        """
        cat, schema = data.split(".")
        return cls(cat, schema)


@dataclass(frozen=True)
class Catalog:
    catalog: str

    @property
    def qualified_name(self):
        return f"{self.catalog}"

    @property
    def name(self):
        return f"{self.catalog}"


def drop_table(table: Table, if_exists: bool = True) -> None:
    """
    Drop table from database
    Parameters
    ----------
    table : Table
        Table to drop
    if_exists : bool
        If True, do not throw error if table does not exist
    """
    if if_exists:
        spark.sql(f"DROP TABLE IF EXISTS {table.qualified_name}")
    else:
        spark.sql(f"DROP TABLE {table.qualified_name}")


def drop_schema(schema: Schema, cascade: bool = False, if_exists: bool = True) -> None:
    """
    Drop schema from database
    Parameters
    ----------
    schema : Schema
        Schema to drop
    cascade : bool
        If True, drop all objects in schema
    if_exists : bool
        If True, do not throw error if schema does not exist
    """
    if if_exists:
        if cascade:
            spark.sql(f"DROP SCHEMA IF EXISTS {schema.qualified_name} CASCADE")
        else:
            spark.sql(f"DROP SCHEMA IF EXISTS {schema.qualified_name}")

    else:
        if cascade:
            spark.sql(f"DROP SCHEMA {schema.qualified_name} CASCADE")
        else:
            spark.sql(f"DROP SCHEMA {schema.qualified_name}")
