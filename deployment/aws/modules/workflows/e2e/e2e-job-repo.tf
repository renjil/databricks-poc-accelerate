resource "databricks_job" "e2e_job_repos" {
  name = "${var.project_name} - E2E (Repos source)"
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

  task {
    task_key = "customer_bronze"
    depends_on {
      task_key = "setup_batch_data"
    }
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
    depends_on {
      task_key = "setup_batch_data"
    }
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
    task_key = "model_train"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "cali_data_setup"
    }

    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_train"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        num_estimators = "6"
      })
    }
  }

  task {
    task_key = "model_deployment"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "model_train"
    }

    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_deployment"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        compare_stag_v_prod = "false"
      })
    }
  }

  task {
    task_key = "model_inference_batch"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "model_deployment"
    }
    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_inference_batch"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
      })
    }
  }
  
  task {
    task_key = "model_train2"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "model_inference_batch"
    }
    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_train"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        num_estimators = "150"
      })
    }
  }

  task {
    task_key = "model_deployment2"
    existing_cluster_id = var.existing_cluster_id
    depends_on {
      task_key = "model_train2"
    }
    notebook_task {
      notebook_path = "${var.repo_path}/src/machine_learning/propval_model_deployment"
      base_parameters = tomap({
        target_catalog = var.catalog_name
        project_name = var.project_name
        compare_stag_v_prod = "true"
      })
    }
  }

  email_notifications {
    no_alert_for_skipped_runs = false
    on_failure = [var.job_email_notification]
  }
}