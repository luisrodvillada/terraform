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

variable "static_s3_bucket_name" {
  type = string
}

resource "aws_iam_policy" "static_s3_read" {
  name = "ec2-read-static-site"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.static_s3_bucket_name}",
          "arn:aws:s3:::${var.static_s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_static_role" {
  name = "ec2-static-site-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_static_policy" {
  role       = aws_iam_role.ec2_static_role.name
  policy_arn = aws_iam_policy.static_s3_read.arn
}

resource "aws_iam_instance_profile" "ec2_static_profile" {
  name = "ec2-static-site-profile"
  role = aws_iam_role.ec2_static_role.name
}
