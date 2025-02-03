provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = var.ecs_cluster_name
}

module "ecs_task_execution_role" {
  source = "terraform-aws-modules/iam/aws"
  name   = "ecs-task-execution-role"

  attach_ecs_task_execution_policy = true
  attach_logs_policy               = true
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
    Version = "2012-10-17"
  })
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.my_ecs_cluster.arn
}
