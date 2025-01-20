locals {
  subnets = cidrsubnets(var.cidr,
    8, 8, 8,
    8, 8, 8,
    4, 4
  )
}

module "vpc" {
  source = "./modules/vpc"

  cidr            = var.cidr
  vpc_name        = ""

  private_subnets = slice(local.subnets, 0, 3)
  public_subnets  = slice(local.subnets, 3, 6)
  db_subnets      = slice(local.subnets, 6, 7)

  region          = ""

  tags = {}
}
