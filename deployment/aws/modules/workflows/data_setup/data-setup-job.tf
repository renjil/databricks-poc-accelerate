resource "databricks_job" "synthetic_data_setup_repos" {
  name = "${var.project_name} - Synthetic Data Setup Job"
  max_concurrent_runs = 1
  timeout_seconds = 86400
  tags = var.tags

  task {
    task_key = "setup_batch_data"
    description = "Setup Batch Data"
    existing_cluster_id = var.existing_cluster_id
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_engineering/setup_batch_data"
      source = "WORKSPACE"
      base_parameters = {
        location        = "s3://${var.data_storage_path}/demo/source"
        target_catalog  = var.catalog_name
        target_database = var.de_database_name
      }
    }
  }

  task {
    task_key = "setup_streaming_data"
    description = "Setup Streaming Data"
    existing_cluster_id = var.existing_cluster_id
    notebook_task {
      notebook_path = "${var.repo_path}/src/data_streaming/setup_streaming_data"
      source = "WORKSPACE"
      base_parameters = {
        location = "s3://${var.data_storage_path}/demo/source/streaming"
      }
    }
  }

  task {
    task_key = "cali_data_setup"
    description = "Cali Data Setup"
    existing_cluster_id = var.existing_cluster_id

    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/data_setup"
      source = "WORKSPACE"
      base_parameters = {
        target_catalog  = var.catalog_name
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