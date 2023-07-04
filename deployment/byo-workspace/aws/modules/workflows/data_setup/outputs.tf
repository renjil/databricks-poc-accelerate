output "synthetic_data_setup_job_repos_id" {
  value = databricks_job.synthetic_data_setup_repos.id
  description = "POC Accelerate Data Setup Job ID -- Repos source"
}

output "synthetic_data_setup_job_repos_url" {
  value       = databricks_job.synthetic_data_setup_repos.url
  description = "POC Accelerate Data Setup Job URL -- Repos source"
}

