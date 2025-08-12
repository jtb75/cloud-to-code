aws_region   = "us-east-2"
environment  = "prod"
project_name = "cloud-to-code"

# VPC Configuration - Different CIDR for prod to avoid conflicts
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"

# EC2 Configuration
instance_type    = "t2.micro"
root_volume_size = 10
ssh_allowed_ips  = ["0.0.0.0/0"] # WARNING: Restrict to specific IPs in production!

# S3 Configuration
s3_versioning_enabled        = true
s3_lifecycle_enabled          = true   # Enable automatic cleanup in prod
s3_lifecycle_expiration_days  = 90     # Keep objects for 90 days in prod
s3_lifecycle_noncurrent_days  = 30     # Keep old versions for 30 days in prod