packer {
  required_version = ">=1.9.0"
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

# --- SOURCE 1: NGINX (Frontend) ---
source "amazon-ebs" "nginx-node" {
  region          = "eu-west-1"
  instance_type   = "t3.micro"
  ssh_username    = "ec2-user"
  source_ami      = "ami-0870af38096a5355b" 
  ami_name        = "nginx-market-{{timestamp}}" # Unique name
  ami_description = "Amazon Linux with Nginx"
}

# --- SOURCE 2: BACKEND (Java & Python) ---
source "amazon-ebs" "backend-node" {
  region          = "eu-west-1"
  instance_type   = "t3.micro"
  ssh_username    = "ec2-user"
  source_ami      = "ami-0870af38096a5355b"
  ami_name        = "backend-market-{{timestamp}}" # Unique name
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
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
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
      "python3 --version" # Verifies install in the logs
    ]
  }
}
