provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloud-to-code"
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    DeployedAt  = timestamp()
  }
}

output "environment" {
  value = var.environment
}

output "region" {
  value = var.aws_region
}

output "deployment_time" {
  value = timestamp()
}