terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source   = "../../modules/networking"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

module "compute" {
  source = "../../modules/compute"

  compute_vpc_id           = module.networking.vpc_id
  compute_public_subnet_id = module.networking.public_subnet_ids[0]
  compute_az               = "us-west-2a"
  compute_key_name         = "mi-key"
}
