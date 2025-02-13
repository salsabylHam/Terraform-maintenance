# data "aws_vpc" "vpc"{
#     id = "vpc-082a23f63852c7895"
# }

# data "aws_subnets" "db_subnets" {
#     filter {
#       name = "vpc-id"
#       values = [data.aws_vpc.vpc.id]
#     }
#     filter {
#       name = "tag:Name"
#       values = ["DB-Subnet-*"]
#     }
    
  
# }


# data "aws_subnets" "public_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.vpc.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["Public-Subnet-*"] # Adaptez cette valeur à vos tags réels.
#   }
# }

# data "aws_subnets" "private_subnets" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.vpc.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["Private-Subnet-*"] # Adaptez cette valeur à vos tags réels.
#   }
# }





