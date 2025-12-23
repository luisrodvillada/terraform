variable "environment" {
  description = "Environment name"
  type        = string
}

variable "log_group_name" {
  description = "Base name for CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 14
}
