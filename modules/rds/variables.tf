variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "environment" {
  type = string
}

variable "backend_sg_id" {
  type = string
}


variable "alb_security_group_id" {
  type = string
}
