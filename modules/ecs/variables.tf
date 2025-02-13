variable "cluster_name" {
  default = "nginx-cluster"
}
variable "image" {
  default = "nginx:latest"
}
variable "container_name" {
  default = "nginx-app"
}
variable "task_cpu" {
  default = 256
}
variable "task_memory" {
  default = 512
}
variable "desired_count" {
  default = 1
}
variable "listener_port" {
  default = 80
  }

variable "ecs_service_name" {
  description = "Nom du service ECS"
  default     = "nginx-service"
}

variable "public_subnets" {
  description = "Liste des sous-réseaux publics pour ECS"
  type        = list(string)
}


  variable "vpc_id" {
    type = string
  
}
