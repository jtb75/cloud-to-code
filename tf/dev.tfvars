aws_region   = "us-east-2"
environment  = "dev"
project_name = "cloud-to-code"

# VPC Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# EC2 Configuration
instance_type    = "t2.micro"
root_volume_size = 8
ssh_allowed_ips  = ["0.0.0.0/0"] # WARNING: Open to world, restrict to your IP for better security