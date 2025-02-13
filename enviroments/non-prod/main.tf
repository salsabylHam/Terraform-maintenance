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

# module "rds" {
#   source = "../../modules/rds"

#   db_name                = "mydb"
#   db_username            = "admin"
#   db_password            = ""
  
#   resource_name_prefix   = "myapp"
#   tags                   = {}
#   vpc_id = data.aws_vpc.vpc.id
#   subnet_ids = data.aws_subnets.db_subnets.ids
# }

# module "ecs" {
#   source               = "../../modules/ecs"
#   cluster_name         = "nginx-cluster"
#   vpc_id = data.aws_vpc.vpc.id
#   image                = "nginx:latest"
#   container_name       = "nginx-app"
#   task_cpu             = 256
#   task_memory          = 512
#   desired_count        = 1
#   ecs_service_name     = "nginx-service"
#   listener_port        = 80
#   public_subnets = data.aws_subnets.public_subnets.ids

# }


# Déclaration du module ECR

# # Module pour le backend
module "ecr_backend" {
  source = "../../modules/ecr"  # Référence au module pour le backend

  repository_name = "back-app"  # Nom du dépôt ECR pour le backend
  tags = {                          # Tags pour le dépôt backend
    "Environment" = "Production"
    "Project"     = "BackendProject"
  }
}

module "ecr_frontend" {
  source = "../../modules/ecr"  # Référence au même module pour le frontend

  repository_name = "front-app"  # Nom du dépôt ECR pour le frontend
  tags = {                            # Tags pour le dépôt frontend
    "Environment" = "Production"
    "Project"     = "FrontendProject"
  }

}
