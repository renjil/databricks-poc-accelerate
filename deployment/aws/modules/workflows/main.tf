module "data_setup" {
    source = "./data_setup"

    # Names and Tags
    project_name = var.project_name
    tags = {
        project = var.project_name
    }
    
    # Email notifications for jobs
    job_email_notification = data.databricks_current_user.me.user_name

    # Data storage
    data_storage_path       = var.data_storage_path
    catalog_name            = var.catalog_name

    # Data storage - DE specific
    de_database_name        = var.de_database_name

    # Git and Repos
    # git_user = var.git_user
    # git_url = var.git_url
    git_branch = var.git_branch
    git_provider = var.git_provider
    # git_pat = var.git_pat
    repo_path               = "/Repos/${data.databricks_current_user.me.user_name}/${var.project_name}"

    # Infrastucture
    existing_cluster_id     = var.dev_cluster_id
    cluster_security_mode = "SINGLE_USER"
    runtime_engine = "PHOTON"
    node_type_id = "i3.xlarge"

}

module "ml" {
    source = "./ml"

    # Names and Tags
    project_name = var.project_name
    tags = {
        project = var.project_name
    }

    # Email notifications for jobs
    job_email_notification = data.databricks_current_user.me.user_name
    
    # Data storage
    catalog_name = var.catalog_name

    # Git and Repos
    # git_user = var.git_user
    # git_url = var.git_url
    # git_branch = var.git_branch
    # git_provider = var.git_provider
    # git_pat = var.git_pat
    repo_path               = "/Repos/${data.databricks_current_user.me.user_name}/${var.project_name}"

    # Infrastucture
    existing_cluster_id     = var.dev_cluster_id

    # Experiments
    experiment_dir_path     = "/Shared/${var.project_name}"

}

module "de" {
    source = "./de"

    # Names and Tags
    project_name = var.project_name
    tags = {
        project = var.project_name
    }

    # Email notifications for jobs
    job_email_notification = data.databricks_current_user.me.user_name
    
    # Data storage
    data_storage_path       = var.data_storage_path
    catalog_name            = var.catalog_name
    de_database_name        = var.de_database_name

    # Git and Repos
    # git_user = var.git_user
    # git_url = var.git_url
    # git_branch = var.git_branch
    # git_provider = var.git_provider
    # git_pat = var.git_pat
    repo_path               = "/Repos/${data.databricks_current_user.me.user_name}/${var.project_name}"

    # Infrastucture
    existing_cluster_id     = var.dev_cluster_id
    cluster_security_mode   = "SINGLE_USER"
    runtime_engine          = "PHOTON"
    node_type_id            = "i3.xlarge"


    
}