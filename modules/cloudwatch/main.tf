resource "aws_cloudwatch_log_group" "this" {
  name              = "/project/${var.environment}/${var.log_group_name}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Service     = var.log_group_name
  }
}
