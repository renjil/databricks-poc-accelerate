resource "databricks_job" "propval_model_train_deploy_repos" {
  name = "${var.project_name} - ML - Deploy Job"

  tags = var.tags

  task {
    task_key = "model_deployment"
    existing_cluster_id = var.existing_cluster_id

    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_deployment"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        compare_stag_v_prod = "false"
      })
    }
  }

  email_notifications {
    on_success = [var.job_email_notification]
    on_failure = [var.job_email_notification]
  }

}
