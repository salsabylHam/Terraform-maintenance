resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_instance_identifier
  instance_class          = var.db_instance_class
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  db_name                 = var.db_name            
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  max_allocated_storage   = 100
  vpc_security_group_ids  = var.security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot     = true

  tags = var.tags
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnets

  tags = {
    Name = "RDS Subnet Group"
  }
}
