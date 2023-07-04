# Deploy Workspace and Assets using Terraform

## Create a tfvar file under the deployment folder for configuring necessary parameters
```
touch db.tfvars
```

## Add below configs to the tfvar file
```
# Databricks credentials
databricks_account_username = "john.doev@doe.com"
databricks_account_password = "XXXX$"
databricks_account_id       = "XX-XX-XX-XX-XX"

# AWS credentials
aws_access_key = "XXXXX"
aws_secret_key = "XXXXX/2KU3AYaueBzfJQeiXFqhE6"
aws_account_id = "123456789"

# Git
git_url  = "https://github.com/databricks/anzmmc-packaged-poc"
git_pat  = "XX"
git_user = "john.doe@doe.com"
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

