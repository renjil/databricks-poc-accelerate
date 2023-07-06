resource "databricks_job" "propval_model_inference_batch_repos" {
  name = "${var.project_name} - ML - Batch Inference Job"
  existing_cluster_id = var.existing_cluster_id
  tags = var.tags

  notebook_task {
    notebook_path = "${var.repo_path}/src/machine_learning/propval_model_inference_batch"
    base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        # env = var.env
    })
  }
  
  email_notifications {
    on_success = [var.job_email_notification]
    on_failure = [var.job_email_notification]
  }

}