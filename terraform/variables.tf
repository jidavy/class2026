variable "project_vpc" {
  type        = string
  description = "The ID of the VPC where resources will be created"
}

variable "project_instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "project_subnet" {
  type        = string
  description = "The Subnet ID for our instances"
}

variable "project_keyname" {
  type        = string
  description = "The name of the SSH key pair created in AWS"
}
