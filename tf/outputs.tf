# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_eip.ec2.public_dns
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "ec2_ssh_private_key" {
  description = "Private SSH key for EC2 instance (KEEP SECURE!)"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh -i ec2-key.pem ec2-user@${aws_eip.ec2.public_ip}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_eip.ec2.public_ip}"
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.main.region
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

# General Outputs
output "environment" {
  value = var.environment
}

output "region" {
  value = var.aws_region
}

output "deployment_time" {
  value = timestamp()
}