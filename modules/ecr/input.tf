variable "repository_name" {
  description = "Nom du dépôt ECR"
  type        = string
}

variable "tags" {
  description = "Tags pour le dépôt ECR"
  type        = map(string)
  default     = {}
}
