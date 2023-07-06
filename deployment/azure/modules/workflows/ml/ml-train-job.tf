resource "databricks_job" "propval_model_train_repos" {
  name = "${var.project_name} - ML - Train Job"

  tags = var.tags

  task {
    task_key = "taskA--model_train"
    existing_cluster_id = var.existing_cluster_id

    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_train"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        num_estimators = "6"
      })
    }
  }

  email_notifications {
    on_success = [var.job_email_notification]
    on_failure = [var.job_email_notification]
  }

}
