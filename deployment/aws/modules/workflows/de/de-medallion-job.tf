resource "databricks_job" "medallion_repos" {
  name = "${var.project_name} - DE - Medallion Job"
  max_concurrent_runs = 1
  timeout_seconds = 86400
  tags = var.tags

  task {
    task_key = "customer_bronze"
    existing_cluster_id = var.existing_cluster_id
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_engineering/lake_to_bronze"
      source = "WORKSPACE"
      base_parameters = {
        format          = "json"
        target_table    = "customer_bronze"
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
        schema_path     = "s3://${var.data_storage_path}/demo/autoloader/schema_customer"
        checkpoint_path = "s3://${var.data_storage_path}/demo/autoloader/checkpoint_customer"
        source_path     = "s3://${var.data_storage_path}/demo/source/customer"
        
      }
    }
  }

  task {
    task_key = "sales_bronze"
    existing_cluster_id = var.existing_cluster_id
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_engineering/lake_to_bronze"
      source = "WORKSPACE"
      base_parameters = {
        format          = "csv"
        target_table    = "sales_bronze"
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
        schema_path     = "s3://${var.data_storage_path}/demo/autoloader/schema_sales"
        checkpoint_path = "s3://${var.data_storage_path}/demo/autoloader/checkpoint_sales"
        source_path     = "s3://${var.data_storage_path}/demo/source/sales"
      }
    }
  }

  task {
    task_key = "store_bronze"
    existing_cluster_id = var.existing_cluster_id
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_engineering/lake_to_bronze"
      source = "WORKSPACE"
      base_parameters = {
        format          = "json"
        target_table    = "store_bronze"
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
        schema_path     = "s3://${var.data_storage_path}/demo/autoloader/schema_store"
        checkpoint_path = "s3://${var.data_storage_path}/demo/autoloader/checkpoint_store"
        source_path     = "s3://${var.data_storage_path}/demo/source/store"
      }
    }
  }

  task {
    task_key = "silver"
    existing_cluster_id = var.existing_cluster_id
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
      notebook_path = "${var.repo_path}/src/data_engineering/bronze_to_silver"
      source = "WORKSPACE"
      base_parameters = {
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
      }
    }
  }

  task {
    task_key = "gold"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "silver"
    }
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_engineering/silver_to_gold"
      source = "WORKSPACE"
      base_parameters = {
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
      }
    }
  }

  schedule {
    timezone_id = "Australia/Melbourne"
    quartz_cron_expression = "20 30 * * * ?"
    pause_status = "PAUSED"
  }

  email_notifications {
    no_alert_for_skipped_runs = false
    on_failure = [var.job_email_notification]
    on_success = [var.job_email_notification]
  }
}