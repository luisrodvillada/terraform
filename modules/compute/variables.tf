variable "compute_vpc_id" {
  type = string
}

variable "compute_public_subnet_id" {
  type = string
}

variable "compute_az" {
  type = string
}

variable "compute_instance_type" {
  type    = string
  default = "t3.micro"
}



variable "compute_tags" {
  type    = map(string)
  default = {}
}

variable "compute_key_name" {
  type        = string
  description = "Nombre de la key SSH"
}
