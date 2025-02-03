output "ecs_cluster_name" {
  value = aws_ecs_cluster.my_ecs_cluster.name
}

output "ecs_service_arn" {
  value = aws_ecs_service.my_ecs_service.arn
}
