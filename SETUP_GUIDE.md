# Two-Account AWS Deployment Setup Guide

This repository is configured for manual deployments to separate AWS accounts for dev and prod environments using GitHub Actions.

## Architecture Overview

- **Dev Workflow** → Manually deploy to Dev AWS Account
- **Prod Workflow** → Manually deploy to Prod AWS Account (with safety confirmations)
- Each environment has its own:
  - S3 state bucket
  - DynamoDB lock table
  - IAM OIDC role
  - Terraform state

## Initial Setup

### Step 1: Setup AWS OIDC for Both Accounts

Run the setup script in each AWS account:

#### For Dev Account:
```bash
# Configure AWS CLI for dev account
aws configure --profile dev

# Run setup script with environment name
AWS_PROFILE=dev ./setup_aws_demo_env.sh init --env dev

# The script will output GitHub secret names like:
# DEV_AWS_ROLE_TO_ASSUME
# DEV_AWS_REGION
# DEV_TF_STATE_BUCKET
# DEV_TF_STATE_DYNAMODB_TABLE
```

#### For Prod Account:
```bash
# Configure AWS CLI for prod account
aws configure --profile prod

# Run setup script with environment name
AWS_PROFILE=prod ./setup_aws_demo_env.sh init --env prod

# The script will output GitHub secret names like:
# PROD_AWS_ROLE_TO_ASSUME
# PROD_AWS_REGION
# PROD_TF_STATE_BUCKET
# PROD_TF_STATE_DYNAMODB_TABLE
```

### Step 2: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

The setup script outputs the exact secret names and values. Copy them directly from the script output.

#### Dev Environment Secrets (from dev setup output):
- `DEV_AWS_ROLE_TO_ASSUME` - IAM role ARN from dev setup
- `DEV_AWS_REGION` - AWS region for dev (e.g., us-east-2)
- `DEV_TF_STATE_BUCKET` - S3 bucket name from dev setup
- `DEV_TF_STATE_DYNAMODB_TABLE` - DynamoDB table name from dev setup

#### Prod Environment Secrets (from prod setup output):
- `PROD_AWS_ROLE_TO_ASSUME` - IAM role ARN from prod setup
- `PROD_AWS_REGION` - AWS region for prod (e.g., us-east-2)
- `PROD_TF_STATE_BUCKET` - S3 bucket name from prod setup
- `PROD_TF_STATE_DYNAMODB_TABLE` - DynamoDB table name from prod setup

**Note**: The script provides copy-paste ready secret names and values in the output.

## Deployment Workflow

### Manual Workflow Triggers

Both workflows are manually triggered through the GitHub Actions UI:

1. Go to Actions tab in your repository
2. Select the workflow (Deploy to Dev or Deploy to Production)
3. Click "Run workflow"
4. Choose your options and run

### Development Deployment

1. Navigate to Actions → Deploy to Dev
2. Click "Run workflow"
3. Select options:
   - **Action**: `plan`, `apply`, or `destroy`
   - **Auto-approve**: Check for automatic approval (optional)
4. Click "Run workflow"

### Production Deployment

1. Navigate to Actions → Deploy to Production
2. Click "Run workflow"
3. Select options:
   - **Action**: `plan`, `apply`, or `destroy`
   - **Auto-approve**: Check for automatic approval (use with caution!)
   - **Confirm production**: Type `PRODUCTION` to confirm
4. Click "Run workflow"

### Workflow Actions

- **plan**: Generate and review Terraform plan without making changes
- **apply**: Apply the Terraform configuration to create/update resources
- **destroy**: Destroy all Terraform-managed resources

### Safety Features

- **Dev Environment**: Simple manual trigger with optional auto-approve
- **Production Environment**: 
  - Requires typing "PRODUCTION" to confirm
  - Creates git tags on successful apply
  - Enhanced warnings for destroy operations

## File Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy-dev.yml     # Dev deployment workflow
│       └── deploy-prod.yml    # Prod deployment workflow
├── tf/
│   ├── main.tf                # Main Terraform configuration
│   ├── dev.tfvars             # Dev environment variables
│   └── prod.tfvars            # Prod environment variables
├── setup_aws_demo_env.sh      # AWS OIDC setup script
└── backend.tf                 # (Generated dynamically, gitignored)
```

## Environment-Specific Configuration

Modify the `.tfvars` files in the `tf/` directory to customize each environment:

- `tf/dev.tfvars` - Development environment configuration
- `tf/prod.tfvars` - Production environment configuration

## Security Best Practices

1. **Never commit secrets** - Use GitHub Secrets for sensitive data
2. **Use OIDC** - No long-lived AWS credentials
3. **Separate state** - Each environment has isolated state
4. **Manual triggers** - Full control over when deployments happen
5. **Production safety** - Extra confirmation required for production
6. **Least privilege** - Scope IAM roles appropriately

## Troubleshooting

### Common Issues

1. **OIDC Authentication Fails**
   - Verify the GitHub repo name in trust policy
   - Check IAM role ARN in secrets
   - Ensure OIDC provider exists in AWS account

2. **State Lock Issues**
   - Check DynamoDB table exists and is accessible
   - Verify table name in secrets matches actual table

3. **S3 Access Denied**
   - Verify bucket exists and is in correct region
   - Check IAM role has necessary S3 permissions

### Cleanup

To destroy resources in an environment:

```bash
# For dev account
AWS_PROFILE=dev ./setup_aws_demo_env.sh destroy --env dev

# For prod account
AWS_PROFILE=prod ./setup_aws_demo_env.sh destroy --env prod
```

### Additional Environments

You can also create additional environments (staging, qa, etc.):

```bash
# For staging environment
AWS_PROFILE=staging ./setup_aws_demo_env.sh init --env staging

# This will output:
# STAGING_AWS_ROLE_TO_ASSUME
# STAGING_AWS_REGION
# STAGING_TF_STATE_BUCKET
# STAGING_TF_STATE_DYNAMODB_TABLE
```

## Recommended Workflow

1. **Development Testing**:
   - Run with action: `plan` first
   - Review the plan output
   - Run with action: `apply` if satisfied

2. **Production Deployment**:
   - Always run `plan` first
   - Review thoroughly
   - Get approval from team
   - Run `apply` with production confirmation

3. **Cleanup**:
   - Use `destroy` action with caution
   - Always review destroy plan first
   - Production requires explicit confirmation

## Next Steps

1. Customize `tf/main.tf` with your infrastructure
2. Update `tf/*.tfvars` files with environment-specific values
3. Test deployment to dev environment first
4. Once validated, deploy to production
5. Consider adding:
   - Terraform fmt/validate checks
   - Cost estimation (Infracost)
   - Security scanning (tfsec, checkov)
   - Slack/email notifications