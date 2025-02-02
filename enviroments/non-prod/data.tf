data "aws_vpc" "vpc"{
    id = "vpc-0cb536ce31d279b8b"
}

data "aws_subnets" "db_subnets" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.vpc.id]
    }
    filter {
      name = "tag:Name"
      values = ["DB-Subnet-*"]
    }
  
}