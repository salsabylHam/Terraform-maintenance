


module "vpc" {
  source = "./modules/vpc"
  vpc_name = ""
  
  cidr = ""
  region = ""
  
  tags = {}
}