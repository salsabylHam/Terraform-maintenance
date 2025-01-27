output "rds_instance_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "rds_instance_arn" {
  value = aws_db_instance.rds_instance.arn
}
