resource "databricks_cluster" "dev" {
  cluster_name            = "${var.project_name}-dev-cluster"
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  autotermination_minutes = var.autotermination_minutes
  data_security_mode      = var.cluster_security_mode
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }
  custom_tags = var.tags
}

resource "databricks_library" "pyyaml" {
  cluster_id = databricks_cluster.dev.id
  pypi {
    package = "pyyaml==6.0"
  }
  
}

resource "databricks_library" "python_dotenv" {
  cluster_id = databricks_cluster.dev.id
  pypi {
    package = "python-dotenv==0.21.1"
  }
  
}

resource "databricks_library" "coolname" {
  cluster_id = databricks_cluster.dev.id
  pypi {
    package = "coolname==2.2.0"
  }
  
}
