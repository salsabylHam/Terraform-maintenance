# Variables
variable "manage_master_user_password" {
  description = "Flag to manage master password via AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Nom d'utilisateur de la base de données"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Mot de passe de la base de données"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_subnets" {
  description = "Liste des sous-réseaux pour RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Liste des ID des groupes de sécurité"
  type        = list(string)
}

variable "tags" {
  description = "Tags pour les ressources"
  type        = map(string)
  default     = {
    Environment = "Production"
  }
}

# Créer un secret dans AWS Secrets Manager pour le mot de passe
resource "aws_secretsmanager_secret" "db_master_password" {
  name        = "rds-master-password"
  description = "Password for RDS Aurora master user"
}

resource "aws_secretsmanager_secret_version" "db_master_password_version" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# Créer un groupe de sécurité pour l'application
resource "aws_security_group" "app_security_group" {
  name        = "app-sg"
  description = "Security group for application access to RDS Aurora"
  vpc_id      = var.vpc_id  # Remplacez par votre VPC ID

  ingress {
    from_port   = 3306  # Port pour MySQL (Aurora MySQL)
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # À personnaliser selon votre configuration
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App Security Group"
  }
}

# Créer un groupe de sécurité pour la base de données
resource "aws_security_group" "db_security_group" {
  name        = "db-sg"
  description = "Security group for database access"
  vpc_id      = var.vpc_id  # Remplacez par votre VPC ID

  ingress {
    from_port   = 3306  # Port pour MySQL
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB Security Group"
  }
}

# Créer un groupe de sous-réseaux pour RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnets  # Liste des sous-réseaux dans les AZs

  tags = {
    Name = "RDS Subnet Group"
  }
}

# Créer un cluster Aurora Serverless
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier          = "example-aurora-cluster"
  database_name               = var.db_name
  engine                      = "aurora-mysql"
  engine_mode                 = "serverless"
  master_username             = var.db_username

  # Gestion du mot de passe (dynamique)
  manage_master_user_password = var.manage_master_user_password

  # Si manage_master_user_password est true, AWS gère le mot de passe via Secrets Manager
  master_password             = var.manage_master_user_password ? null : var.db_password

  backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot         = true

  vpc_security_group_ids = [
    aws_security_group.db_security_group.id,
    aws_security_group.app_security_group.id
  ]

  tags = var.tags
}

# Créer une instance Aurora Serverless
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 1  # Spécifiez le nombre d'instances souhaitées
  cluster_identifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  instance_class     = "db.serverless"
  engine             = "aurora-mysql"

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  tags = var.tags
}

# Sortie pour afficher les informations
output "rds_cluster_endpoint" {
  description = "Endpoint of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "rds_cluster_instance_endpoint" {
  description = "Endpoint of the Aurora RDS instance"
  value       = aws_rds_cluster_instance.aurora_instance[0].endpoint
}
