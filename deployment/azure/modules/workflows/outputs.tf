output "medallion_job_id" {
  value = databricks_job.medallion.id
  description = "POC Accelerate Medallion Job ID"
}

output "medallion_job_url" {
  value       = databricks_job.medallion.url
  description = "POC Accelerate Medallion Job URL"
}

output "synthetic_data_setup_job_id" {
  value = databricks_job.synthetic_data_setup.id
  description = "POC Accelerate Data Setup Job ID"
}

output "synthetic_data_setup_job_url" {
  value       = databricks_job.synthetic_data_setup.url
  description = "POC Accelerate Data Setup Job URL"
}

output "streaming_job_id" {
  value = databricks_job.streaming_job.id
  description = "POC Accelerate Streaming Job ID"
}

output "streaming_job_url" {
  value       = databricks_job.streaming_job.url
  description = "POC Accelerate Streaming Job URL"
}

