variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
  default     = "vpc-lab"
}



variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs de subredes privadas"
  type        = list(string)
}

