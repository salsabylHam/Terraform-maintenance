locals {
  subnets = cidrsubnets(var.cidr,
    3, 3, 3,
    3, 3, 3,
    4, 4
  )
}

module "vpc" {
  source = "../../modules/vpc"

  cidr            = var.cidr
  vpc_name        = "my-vpc"

  private_subnets = slice(local.subnets, 0, 3)
  public_subnets  = slice(local.subnets, 3, 6)
  db_subnets      = slice(local.subnets, 6, 8)

  region          = "eu-west-3"   # Assurez-vous de passer la région ici
  tags            = {}
}


module "rds" {
  source = "../../modules/rds"

  db_name                = "mydb"
  db_username            = "admin"
  db_password            = ""
  
  resource_name_prefix   = "myapp"
  tags                   = {}
  vpc_id = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.db_subnets.ids
}






