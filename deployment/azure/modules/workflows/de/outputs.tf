output "medallion_job_repos_id" {
  value = databricks_job.medallion_repos.id
  description = "POC Accelerate Medallion Job ID -- Repos source"
}

output "medallion_job_repos_url" {
  value       = databricks_job.medallion_repos.url
  description = "POC Accelerate Medallion Job URL -- Repos source"
}

