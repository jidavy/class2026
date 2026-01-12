variable "project_vpc" { type = string }
variable "project_instance_type" { type = string }
variable "project_subnet" { type = string }
variable "project_keyname" { type = string }

# Separate AMI variables for each tier
variable "nginx_ami_id" { type = string }
variable "backend_ami_id" { type = string }
