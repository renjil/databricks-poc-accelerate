resource "databricks_job" "medallion" {
  name = "POC Accelerate - Medallion"
  max_concurrent_runs = 1
  timeout_seconds = 86400
  tags = {
    project = "poc-accelerate"
  }

  job_cluster {
    job_cluster_key = "medallion_job_cluster"
    new_cluster {
      spark_version      = var.latest_lts
      runtime_engine     = var.runtime_engine
      node_type_id = var.node_type
      data_security_mode = var.cluster_security_mode
      autoscale {
        min_workers = 1
        max_workers = 2
      }
      custom_tags = {
        project = "poc-accelerate"
      }
    }
  }

  task {
    task_key = "customer_bronze"
    job_cluster_key = "medallion_job_cluster"
    notebook_task {
      notebook_path = "src/data_engineering/lake_to_bronze"
      source = "GIT"
      base_parameters = {
        format          = "json"
        target_table    = "customer_bronze"
        target_catalog  = var.catalog_name
        target_database = var.target_database
        schema_path     = "${local.adls_storage}/demo/autoloader/schema_customer"
        checkpoint_path = "${local.adls_storage}/demo/autoloader/checkpoint_customer"
        source_path     = "${local.adls_storage}/demo/source/customer"
        
      }
    }
  }

  task {
    task_key = "sales_bronze"
    job_cluster_key = "medallion_job_cluster"
    notebook_task {
      notebook_path = "src/data_engineering/lake_to_bronze"
      source = "GIT"
      base_parameters = {
        format          = "json"
        target_table    = "customer_bronze"
        target_catalog  = var.catalog_name
        target_database = var.target_database
        schema_path     = "${local.adls_storage}/demo/autoloader/schema_sales"
        checkpoint_path = "${local.adls_storage}/demo/autoloader/checkpoint_sales"
        source_path     = "${local.adls_storage}/demo/source/sales"
      }
    }
  }

  task {
    task_key = "store_bronze"
    job_cluster_key = "medallion_job_cluster"
    notebook_task {
      notebook_path = "src/data_engineering/lake_to_bronze"
      source = "GIT"
      base_parameters = {
        format          = "json"
        target_table    = "store_bronze"
        target_catalog  = var.catalog_name
        target_database = var.target_database
        schema_path     = "${local.adls_storage}/demo/autoloader/schema_store"
        checkpoint_path = "${local.adls_storage}/demo/autoloader/checkpoint_store"
        source_path     = "${local.adls_storage}/demo/source/store"
      }
    }
  }

  task {
    task_key = "silver"
    job_cluster_key = "medallion_job_cluster"
    depends_on {
      task_key = "customer_bronze"
    }
    depends_on {
      task_key = "sales_bronze"
    }
    depends_on {
      task_key = "store_bronze"
    }
    notebook_task {
      notebook_path = "src/data_engineering/bronze_to_silver"
      source = "GIT"
    }
  }

  task {
    task_key = "gold"
    job_cluster_key = "medallion_job_cluster"
    depends_on {
      task_key = "silver"
    }
    notebook_task {
      notebook_path = "src/data_engineering/silver_to_gold"
      source = "GIT"
    }
  }

  git_source {
    url = var.git_url
    provider = "gitHub"
    branch = "main"
  }

  schedule {
    timezone_id = "Australia/Melbourne"
    quartz_cron_expression = "20 30 * * * ?"
    pause_status = "PAUSED"
  }

  email_notifications {
    no_alert_for_skipped_runs = false
    on_failure = [var.job_email_notification]
  }
}