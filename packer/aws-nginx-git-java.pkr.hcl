packer {
  required_version = ">= 1.9.0"
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

# This variable adds a timestamp so every build has a unique name
variable "timestamp" {
  type    = string
  default = "{{timestamp}}"
}

# --- DATA SOURCE: Find the latest Amazon Linux 2023 AMI ---
data "amazon-ami" "amazon-linux-2023" {
  filters = {
    name                = "al2023-ami-2023*-x86_64"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["137112412989"] # This is the official Amazon Owner ID
  region      = "eu-west-1"
}

# --- SOURCE 1: NGINX (Frontend) ---
source "amazon-ebs" "nginx-node" {
  region          = "eu-west-1"
  instance_type   = "t3.micro"
  ssh_username    = "ec2-user"
  # Use the data source here instead of a hardcoded ID
  source_ami      = data.amazon-ami.amazon-linux-2023.id
  ami_name        = "nginx-market-${var.timestamp}" 
  ami_description = "Amazon Linux with Nginx"
}

# --- SOURCE 2: BACKEND (Java & Python) ---
source "amazon-ebs" "backend-node" {
  region          = "eu-west-1"
  instance_type   = "t3.micro"
  ssh_username    = "ec2-user"
  # Use the data source here instead of a hardcoded ID
  source_ami      = data.amazon-ami.amazon-linux-2023.id
  ami_name        = "backend-market-${var.timestamp}" 
  ami_description = "Amazon Linux with Java 17 and Python 3"
}

# --- BUILD 1: Frontend ---
build {
  name    = "frontend-build"
  sources = ["source.amazon-ebs.nginx-node"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install nginx git -y",
      "sudo systemctl enable nginx"
    ]
  }
}

# --- BUILD 2: Backend ---
build {
  name    = "backend-build"
  sources = ["source.amazon-ebs.backend-node"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install java-17-amazon-corretto python3 git -y",
      "java -version",
      "python3 --version"
    ]
  }
}
