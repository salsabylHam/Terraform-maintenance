variable "db_instance_identifier" {
  description = "Nom de l'instance RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Classe de l'instance RDS"
  type        = string
}

variable "db_engine" {
  description = "Moteur de base de données"
  type        = string
}

variable "db_engine_version" {
  description = "Version du moteur de base de données"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_username" {
  description = "Nom d'utilisateur pour l'instance RDS"
  type        = string
}

variable "db_password" {
  description = "Mot de passe pour l'instance RDS"
  type        = string
  sensitive   = true
}

variable "db_subnets" {
  description = "Subnets où déployer l'instance RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Liste des groupes de sécurité pour l'instance RDS"
  type        = list(string)
}

variable "tags" {
  description = "Tags pour l'instance RDS"
  type        = map(string)
}
