variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc)"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed with objects (dev only)"
  type        = bool
  default     = false
}
