# Deploy Workspace and Assets using Terraform

## Create a tfvar file under the deployment folder for configuring necessary parameters
```
touch db.tfvars
```

## Add below configs to the tfvar file (AWS)
```
databricks_account_username = "john.doe@databricks.com"
databricks_account_password = "supersecretpassword"
databricks_account_id = "XXX-XXX-XXX-XXX-XXX"
aws_access_key = "XXX"
aws_secret_key = "XXX/2KU3AYaueBzfJQeiXFqhE6"
aws_account_id = "123456789"
metastore_storage_label = "uc"
metastore_name = "poc_accelerate_metastore"
metastore_label = "metastore"

# cluster variables
autotermination_minutes = 20
cluster_security_mode = "SINGLE_USER"
min_workers = 1
max_workers = 2
sql_cluster_size = "2X-Small"
# sql_warehouse_name = "poc_accelerate_wh"

# workflows
catalog_name           = "poc_accelerate"
de_database_name          = "synthetic_db"
job_email_notification = "john.doe@databricks.com"
git_url                = "https://github.com/renjil/databricks-poc-accelerate"
git_pat = "xxxxxxxx"
git_user = "john.doe@github.com"
```

## Add below configs to the .tfvars file (AZURE)
job_email_notification = "myuser@databricks.com"
project_name = "poc"
owner = "myuser@databricks.com"
```

## First initialize terraform

```
terraform init
```

## Run terraform plan
```
terraform plan -var-file="db.tfvars"
```

## Deploy 
```
terraform apply -var-file="db.tfvars" -auto-approve
```

