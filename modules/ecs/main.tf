resource "aws_ecs_cluster" "nginx_cluster" {
  name = var.cluster_name
}

# rôle IAM pour exécuter les tâches ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.cluster_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}



# Définition de la politique IAM attachée au rôle

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Définition de la task definition ECS
resource "aws_ecs_task_definition" "nginx_task_definition" {
  family                   = var.container_name
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image
      essential = true
      portMappings = [{
        containerPort = var.listener_port
      }]
    }
  ])
}

# Déploiement du service ECS
resource "aws_ecs_service" "nginx_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task_definition.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = var.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
#Configuration du Security Group
resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.cluster_name}-sg"
  vpc_id      = var.vpc_id

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
