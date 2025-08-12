# Security Group for EC2
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-sg"
    }
  )
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-key"
    }
  )
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.ec2_key.key_name
  subnet_id            = aws_subnet.public.id
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-root-volume"
      }
    )
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd aws-cli
    systemctl start httpd
    systemctl enable httpd
    
    # Create web page
    echo "<h1>Hello from ${var.environment} environment!</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
    echo "<p>S3 Bucket: ${aws_s3_bucket.main.id}</p>" >> /var/www/html/index.html
    
    # Test S3 access
    echo "Testing S3 access to bucket: ${aws_s3_bucket.main.id}" > /tmp/test.txt
    aws s3 cp /tmp/test.txt s3://${aws_s3_bucket.main.id}/test/instance-test.txt --region ${var.aws_region}
  EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2"
    }
  )
}

# Elastic IP for EC2 (optional - for consistent public IP)
resource "aws_eip" "ec2" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-eip"
    }
  )
}