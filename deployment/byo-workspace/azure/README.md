# Deploy Workspace and Assets using Terraform

## Create a tfvar file under the deployment folder for configuring necessary parameters
```
touch db.tfvars
```

## Add below configs to the tfvar file
```
# Databricks credentials
databricks_account_username = "john.doev@doe.com"

# Workflows
job_email_notification = "john.doe@doe.com"

# Git
git_pat = "XX"
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

