data "databricks_node_type" "smallest" {
  local_disk = true
}

# data "databricks_spark_version" "ml-latest" {
#   latest = true
#   long_term_support = false
#   ml = true
#   beta = true
# }

resource "databricks_cluster" "dev" {
  cluster_name            = "${var.project_name}-dev-cluster"
  spark_version           = "13.2.x-cpu-ml-scala2.12"
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = var.autotermination_minutes
  data_security_mode      = var.cluster_security_mode
  # single_user_name        = data.databricks_current_user.me.user_name
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }
  aws_attributes {
    availability           = "SPOT_WITH_FALLBACK"
    zone_id                = "ap-southeast-2a"
    first_on_demand        = 1
    spot_bid_price_percent = 100
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
