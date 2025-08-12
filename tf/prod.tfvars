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