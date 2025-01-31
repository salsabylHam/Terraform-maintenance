terraform {
  backend "s3" {
    bucket         = "backend-tfstates-tf"        # Nom de ton bucket
    key            = "salsabil/testing/terraform.tfstate"  # Chemin personnalisé pour l'état
    region         = "eu-west-3"                  # Région AWS
    encrypt        = true                         # Chiffrement des données
  }
}
