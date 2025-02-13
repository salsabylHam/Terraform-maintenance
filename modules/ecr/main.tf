resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.repository_name  # Utilise la variable repository_name pour chaque dépôt
  image_tag_mutability = "MUTABLE"            # Choix entre 'MUTABLE' et 'IMMUTABLE'
  tags = var.tags                            # Tags passés en variable
}

