terraform {
  backend "s3" {
    bucket  = "techxxx-cicd-state-bucket"
    key     = "envs/dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# ---------------------------------------------------------
# DATA SOURCES: VPC and Subnet
# ---------------------------------------------------------
# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch a default subnet in the VPC
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  default_for_az    = true
  availability_zone = "eu-west-1a"  # Adjust if needed
}

# ---------------------------------------------------------
# STEP 1: Search for the latest AMIs built by Packer
# ---------------------------------------------------------
data "aws_ami" "latest_nginx" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["nginx-market-*"]
  }
}

data "aws_ami" "latest_backend" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["backend-market-*"]
  }
}

# ---------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------
# Frontend Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Backend Security Group (Ports 8080 and 9090)
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Python Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Java Port"
    from_port   = 9090
    to_port     = 9090
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

# ---------------------------------------------------------
# STEP 2: EC2 INSTANCES (Linked to Data Sources)
# ---------------------------------------------------------
# Node 1: Frontend (Nginx)
resource "aws_instance" "web-node" {
  ami                    = data.aws_ami.latest_nginx.id
  instance_type          = var.project_instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.project_keyname

  tags = { Name = "web-node-frontend" }
}

# Node 2: Python Backend (Port 8080)
resource "aws_instance" "python-node" {
  ami                    = data.aws_ami.latest_backend.id
  instance_type          = var.project_instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.project_keyname

  tags = { Name = "python-node-backend" }
}

# Node 3: Java Backend (Port 9090)
resource "aws_instance" "java-node" {
  ami                    = data.aws_ami.latest_backend.id
  instance_type          = var.project_instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.project_keyname

  tags = { Name = "java-node-backend" }
}

# ---------------------------------------------------------
# OUTPUTS
# ---------------------------------------------------------
output "frontend_public_ip" {
  value = aws_instance.web-node.public_ip
}
