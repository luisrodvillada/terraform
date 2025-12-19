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

module "compute" {
  source = "../../modules/compute"

  # 🔴 OBLIGATORIAS (YA EXISTÍAN)
  compute_vpc_id           = module.networking.vpc_id
  compute_public_subnet_id = module.networking.public_subnet_ids[0]
  compute_az               = "us-west-2a"
  compute_key_name         = "mi-key"

  compute_tags = {
    Environment = "dev"
    Project     = "terraform-web"
  }

  # 🆕 NUEVA (IAM S3)
  static_s3_bucket_name = module.static_site_s3.static_bucket_name
}
