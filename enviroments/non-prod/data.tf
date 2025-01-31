data "aws_vpc" "vpc"{
    id = "vpc-0c4e460920739732b"
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