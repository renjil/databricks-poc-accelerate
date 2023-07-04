resource "databricks_job" "synthetic_data_setup" {
  name = "POC Accelerate - Synthetic Data Setup"
  max_concurrent_runs = 1
  timeout_seconds = 86400
  tags = {
    project = "poc-accelerate"
  }

  job_cluster {
    job_cluster_key = "data_setup_job_cluster"
    new_cluster {
      spark_version           = var.latest_lts
      node_type_id = var.node_type
      runtime_engine          = var.runtime_engine
      data_security_mode      = var.cluster_security_mode
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
    task_key = "setup_batch_data"
    description = "Setup Batch Data"
    job_cluster_key = "data_setup_job_cluster"
    notebook_task {
      notebook_path = "src/data_engineering/setup_batch_data"
      source = "GIT"
      base_parameters = {
        location        = "${local.adls_storage}/demo/source"
        target_catalog  = var.catalog_name
        target_database = var.database_name
      }
    }
  }

  task {
    task_key = "setup_streaming_data"
    description = "Setup Streaming Data"
    job_cluster_key = "data_setup_job_cluster"
    notebook_task {
      notebook_path = "src/data_engineering/setup_streaming_data"
      source = "GIT"
      base_parameters = {
        location = "${local.adls_storage}/demo/source/streaming"
      }
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