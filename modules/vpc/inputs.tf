variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "db_subnets" {
  description = "List of DB subnets CIDR blocks"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}
# variables.tf dans le module vpc
variable "region" {
  description = "AWS region"
  type        = string
}

