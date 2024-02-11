# Creates and EC2 instance with the default security group

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1" 
}

# VPC and Network Configuration
resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "ap-south-1a"  
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "ap-south-1b"  
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}



# Security Group configuration

resource "aws_security_group" "custom_security_group" {
  name = "adarsh_terraform"
  description = "Security group for adarsh_terraform instance"
  vpc_id      = aws_vpc.main.id

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "custom_security_group_database" {
  name = "adarsh_database_terraform"
  description = "Security group for adarsh_terraform database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306  # MySQL default port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

}

# Instances provisioning
resource "aws_instance" "adarsh_terraform" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  subnet_id       = aws_subnet.public.id
  key_name        = "adarsh"  # Change to your key pair
  vpc_security_group_ids  = [aws_security_group.custom_security_group.id]
#   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group

  tags = {
    Name = "adarsh_mern_terraform"
  }
}

resource "aws_instance" "adarsh_database" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = "adarsh"  # Change to your key pair
  vpc_security_group_ids  = [aws_security_group.custom_security_group_database.id]
#   vpc_security_group_ids = [aws_security_group.adarsh_terraform.id]  # Reference the existing security group

  tags = {
    Name = "adarsh_database_terraform"
  }
}

# Creation of IAM policies

data "aws_iam_policy_document" "loadbalancer" {
  statement {
    sid       = "Statement1"
    effect    = "Allow"
    actions   = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "Statement2"
    effect    = "Allow"
    actions   = [
      "ec2:DescribeInstances",
      "ec2:DescribeClassicLinkInstances",
      "ec2:DescribeSecurityGroups",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "Statement3"
    effect    = "Allow"
    actions   = ["arc-zonal-shift:GetManagedResource"]
    resources = ["arn:aws:elasticloadbalancing:*:*:loadbalancer/*"]
  }

  statement {
    sid       = "Statement4"
    effect    = "Allow"
    actions   = [
      "arc-zonal-shift:ListManagedResources",
      "arc-zonal-shift:ListZonalShifts",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "loadbalancer_policy" {
  name   = "load_balancer_mern"
  policy = data.aws_iam_policy_document.loadbalancer.json
}

# Displaying the output
output "adarsh_terraform_instance_ip" {
  value = aws_instance.adarsh_terraform.public_ip
}

output "adarsh_database_terraform_instance_ip" {
  value = aws_instance.adarsh_terraform.public_ip
}
