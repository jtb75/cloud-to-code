# Terraform Configuration

This directory contains the Terraform configuration for the cloud-to-code project.

## Backend Configuration

The `backend.tf` file defines an S3 backend with encryption enabled. The specific backend configuration (bucket, key, region, DynamoDB table) is provided at runtime via the GitHub Actions workflows using `-backend-config` flags.

This approach allows us to:
- Use the same Terraform code for multiple environments (dev, prod)
- Keep sensitive backend configuration in GitHub Secrets
- Maintain environment isolation with different state files

## Environment-Specific Configuration

- `dev.tfvars` - Development environment variables
- `prod.tfvars` - Production environment variables

## Files

- `backend.tf` - S3 backend configuration (parameters provided at runtime)
- `main.tf` - Main Terraform configuration and resources
- `dev.tfvars` - Development environment values
- `prod.tfvars` - Production environment values

## Local Development

To initialize Terraform locally for development:

```bash
terraform init \
  -backend-config="bucket=YOUR_DEV_BUCKET" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=YOUR_DEV_TABLE"
```

Then run plans with:
```bash
terraform plan -var-file="dev.tfvars"
```