# variable "region" {
#   description = "AWS region"
#   type        = string
# }

# variable "tags" {
#   description = "Tags for the resources"
#   type        = map(string)
# }


variable "cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.4.0.0/16"  # Exemple de CIDR
}
