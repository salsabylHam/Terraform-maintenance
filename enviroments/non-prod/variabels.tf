variable "cidr" {
  type = string
   
}
variable "db_instance_identifier" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}
