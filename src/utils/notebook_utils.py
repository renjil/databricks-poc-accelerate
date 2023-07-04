import os
import pathlib
import dotenv
import yaml
import pprint
from typing import Dict, Any

# relative_conf_path = os.path.join(os.pardir)
relative_conf_path = os.curdir


def load_and_set_env_vars(
    relative_conf_path: str = relative_conf_path,
) -> Dict[str, Any]:
    """
    Utility function to use in Databricks notebooks to load .env files and set them via os
    Return a dict of set environment variables
    Parameters
    ----------
    relative_conf_path : str
        Directory containing the .env file relative to the notebook running the function
    Returns
    -------
    Dictionary of set environment variables
    """
    path = os.path.join(relative_conf_path, "conf", "env_vars", ".workshop.env")
    dotenv.load_dotenv(path)

    os_dict = dict(os.environ)
    pprint.pprint(os_dict)

    return os_dict


def load_config(
    config_name: str, relative_conf_path: str = relative_conf_path
) -> Dict[str, Any]:
    """
    Utility function to use in Databricks notebooks to load the config yaml file for a given pipeline
    Return dict of specified config params
    Parameters
    ----------
    pipeline_name :  str
        Name of pipeline
    relative_conf_path : str
        Directory containing the config file relative to the notebook running the function
    Returns
    -------
    Dictionary of config params
    """
    config_path = os.path.join(
        relative_conf_path, "conf", "pipeline_configs", f"{config_name}.yml"
    )
    pipeline_config = yaml.safe_load(pathlib.Path(config_path).read_text())
    # pprint.pprint(pipeline_config)
    return pipeline_config
