variable "alb_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}
//Conecta S3 con ALB para logs
variable "alb_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}
