locals {
  subnets = cidrsubnets(var.cidr,
    3, 3, 3,
    3, 3, 3,
    4, 4
  )
}

module "vpc" {
  source = "./modules/vpc"

  cidr            = var.cidr
  vpc_name        = "my-vpc"

  private_subnets = slice(local.subnets, 0, 3)
  public_subnets  = slice(local.subnets, 3, 6)
  db_subnets      = slice(local.subnets, 6, 8)

  region          = ""

  tags = {}
}

module "rds" {
  source                = "../../modules/rds"
  db_instance_identifier = "my-rds-instance"
  db_instance_class      = "db.t3.micro"
  db_engine              = "mysql"
  db_engine_version      = "8.0.28"
  db_name                = "mydatabase"
  db_username            = "admin"
  db_password            = "SuperSecurePassword123"
  db_subnets             = module.vpc.db_subnets
  security_group_ids     = [module.vpc.default_sg_id] # Utilisez le SG du module VPC
  tags = {
    Environment = "dev"
    Project     = "PFE"
  }
}

