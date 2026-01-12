# ... (Keep your terraform {} and provider blocks the same) ...

# -------------------------
# Security Groups
# -------------------------

# Security Group for Frontend (Port 80)
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = var.project_vpc

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

# Security Group for Backend (Ports 8080 & 9090)
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = var.project_vpc

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

# -------------------------
# EC2 Instances
# -------------------------

# Node 1: Frontend
resource "aws_instance" "web-node" {
  ami                    = var.nginx_ami_id
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.project_keyname
  tags = { Name = "web-node-frontend" }
}

# Node 2: Python Backend
resource "aws_instance" "python-node" {
  ami                    = var.backend_ami_id
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.project_keyname
  tags = { Name = "python-node-backend" }
}

# Node 3: Java Backend
resource "aws_instance" "java-node" {
  ami                    = var.backend_ami_id
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.project_keyname
  tags = { Name = "java-node-backend" }
}
