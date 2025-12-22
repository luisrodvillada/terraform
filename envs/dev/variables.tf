variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "vpc-dev"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

variable "asg_ami_id" {
  default = "ami-03f65b8614a860c29"
}


variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

