variable "region" {
  description = "AWS region"
  //default     = "eu-west-1"
}
variable "vpc_name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "tags" {
  type    = any
  default = {}
}
