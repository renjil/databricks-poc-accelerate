resource "databricks_job" "streaming_job" {
  name = "POC Accelerate - Streaming Analytics"
  max_concurrent_runs = 1
  timeout_seconds = 86400
  tags = {
    project = "poc-accelerate"
  }

  job_cluster {
    job_cluster_key = "streaming_job_cluster"
    new_cluster {
      spark_version           = var.latest_lts
      node_type_id            = var.node_type
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
    task_key = "weather_report"
    description = "Weather Report"
    job_cluster_key = "streaming_job_cluster"
    notebook_task {
      notebook_path = "src/data_streaming/process_stream"
      source = "GIT"
      base_parameters = {
        checkpoint_path = "${local.adls_storage}/demo/streaming/autoloader/checkpoint_weather"
        schema_path     = "${local.adls_storage}/demo/streaming/autoloader/schema_weather"
        source_path     = "${local.adls_storage}/demo/streaming/weather"
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