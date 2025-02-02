# #Créer un secret dans AWS Secrets Manager pour le mot de passe
# resource "aws_secretsmanager_secret" "db_master_password" {
#   count       = var.manage_master_user_password ? 1 : 0
#   name        = "${var.resource_name_prefix}-rds-master2-password"
#   description = "Password for RDS Aurora master user"

#   # Adding a `kms_key_id` if you want to encrypt the secret with a custom KMS key
#   # kms_key_id = "your-kms-key-id"
# }

# resource "aws_secretsmanager_secret_version" "db_master_password_version" {
#   count         = var.manage_master_user_password ? 1 : 0
#   secret_id     = aws_secretsmanager_secret.db_master_password[count.index].id  # Use count.index to ensure it links properly
#   secret_string = jsonencode({
#     username = var.db_username
#     password = var.db_password
#   })
# }

# # Créer un groupe de sécurité pour l'application
resource "aws_security_group" "app_security_group" {
  name        = "${var.resource_name_prefix}-app-sg"
  description = "Security group for application access to RDS Aurora"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefix}-App Security Group"
  }
}

# Créer un groupe de sécurité pour la base de données
resource "aws_security_group" "db_security_group" {
  name        = "${var.resource_name_prefix}-db-sg"
  description = "Security group for database access"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    //cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_name_prefix}-DB Security Group"
  }
}

# Créer un groupe de sous-réseaux pour RDS
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}
 

# Créer un cluster Aurora Provisioned
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier          = "${var.resource_name_prefix}-aurora-cluster"
  database_name               = var.db_name
  engine                      = "aurora-mysql"
  engine_mode                 = "provisioned"  # Utilisation du mode "provisioned"
  master_username             = var.db_username
  manage_master_user_password = var.manage_master_user_password
  master_password             = var.manage_master_user_password ? null : var.db_password
  

  backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.default.name

  skip_final_snapshot         = true

  vpc_security_group_ids = [
    aws_security_group.db_security_group.id,
    aws_security_group.app_security_group.id
  ]

  tags = var.tags
}

# Créer une instance Aurora Provisioned
resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier   = aws_rds_cluster.aurora_cluster.cluster_identifier
  instance_class       = "db.r5.large"  # Exemple d'instance provisionnée
  engine               = "aurora-mysql"
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = var.tags
}





###########################################################################
# Créer un cluster Aurora Serverless
# # Créer un cluster Aurora Serverless avec scaling automatique
# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier          = "${var.resource_name_prefix}-aurora-cluster"
#   database_name               = var.db_name
#   engine                      = "aurora-mysql"
#   engine_mode                 = "serverless"  # Utilisation de Aurora Serverless
#   master_username             = var.db_username
#   manage_master_user_password = var.manage_master_user_password
#   master_password             = var.manage_master_user_password ? null : var.db_password

#   # Configuration du scaling automatique
#   scaling_configuration {
#     auto_pause               = true  # Active la mise en pause automatique
#     min_capacity             = 2     # Capacité minimum d'unités Aurora
#     max_capacity             = 64    # Capacité maximum d'unités Aurora
#     seconds_until_auto_pause = 300   # Temps d'inactivité avant de mettre le cluster en pause
#   }

#   backup_retention_period     = 7
#   db_subnet_group_name        = aws_db_subnet_group.default.name
#   skip_final_snapshot         = true

#   vpc_security_group_ids = [
#     aws_security_group.db_security_group.id,
#     aws_security_group.app_security_group.id
#   ]

#   tags = var.tags
# }

# # Pas besoin de créer une instance RDS supplémentaire pour Aurora Serverless
# # En mode Serverless, le cluster gère automatiquement les instances et leur scaling.
# # Nous supprimons donc la ressource aws_rds_cluster_instance.
