variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
}


variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "manage_master_user_password" {
  type = bool
  default = true
}
variable "db_password" {
    type = string
  
}

variable "vpc_id" {
    type = string
  
}

variable "subnet_ids" {
  type = any
}

