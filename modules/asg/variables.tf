variable "asg_ami_id" {
  type = string
}

variable "asg_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_key_name" {
  type = string
}

variable "asg_user_data" {
  type = string
}

variable "asg_security_group_ids" {
  type = list(string)
}

variable "asg_public_subnet_ids" {
  type = list(string)
}

variable "asg_target_group_arn" {
  type = string
}

variable "asg_s3_bucket_name" {
  type = string
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}
