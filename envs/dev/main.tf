terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "static_site_s3" {
  source = "../../modules/s3_static_site"

  static_bucket_name = "mi-bucket-luis-fernando"
  local_static_path  = "../../catalogo"
}

module "alb" {
  source = "../../modules/alb"

  alb_name          = "web-alb-dev"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_logs_bucket   = module.s3.bucket_name

}

module "compute" {
  source = "../../modules/compute"

  # 🔹 VARIABLES OBLIGATORIAS DEL COMPUTE
  compute_vpc_id           = module.networking.vpc_id
  compute_public_subnet_id = module.networking.public_subnet_ids[0]
  compute_az               = "us-west-2a"
  compute_key_name         = "mi-key"

  compute_tags = {
    Environment = "dev"
    Project     = "terraform-web"
  }

  # 🔹 S3 (WEB ESTÁTICA)
  static_s3_bucket_name = module.static_site_s3.static_bucket_name

  # 🔹 ALB (CONEXIÓN CORRECTA)
  alb_target_group_arn  = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
}

# Llamar a ASG

module "asg" {
  source = "../../modules/asg"

  asg_ami_id             = var.asg_ami_id
  asg_key_name           = "mi-key"
  asg_user_data          = file("../../modules/asg/user-data.sh")
  asg_security_group_ids = [module.alb.alb_security_group_id]
  asg_public_subnet_ids  = module.networking.public_subnet_ids
  asg_target_group_arn   = module.alb.target_group_arn
  asg_s3_bucket_name     = module.static_site_s3.static_bucket_name
}

//Parametros SSM para RDS - Credenciales seguras

resource "aws_ssm_parameter" "db_username" {
  name  = "/app/db/username"
  type  = "String"
  value = "appuser"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/app/db/password"
  type  = "SecureString"
  value = "CAMBIA_ESTO_POR_ALGO_SEGURO"
}


//Llamar modulo RDS

module "rds" {
  source = "../../modules/rds"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  db_name               = "appdb"
  db_username           = aws_ssm_parameter.db_username.value
  db_password           = aws_ssm_parameter.db_password.value
  alb_security_group_id = module.alb.alb_sg_id
  backend_sg_id         = module.compute.compute_sg_id
  environment           = "dev"
}


//Modulo de s3 para logs

module "s3" {
  source = "../../modules/s3"

  bucket_name   = "project-dev-logs-luisrod"
  environment   = "dev"
  force_destroy = true
}


//Cloudwatch

module "cloudwatch_ec2" {
  source = "../../modules/cloudwatch"

  environment       = "dev"
  log_group_name    = "ec2"
  retention_in_days = 14
}
