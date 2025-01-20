locals {
  subnets = cidrsubnet(var.cidr, 8, )
}

# Créer un VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr # Plage d'adresses IP pour tout le VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = var.vpc_name
  }, var.tags)
}

# Data pour zones de disponibilité cette resoucrce recupere les zone dispo awd dans le regison active 
data "aws_availability_zones" "available" {}

# Subnets publics
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

# Subnets privés
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-Subnet-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "InternetGateway-${var.vpc_name}"
  }
}

# Route Table pour Subnets Publics
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Route vers Internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RouteTable"
  }
}

# Attacher les Subnets Publics à la Table de Routage
resource "aws_route_table_association" "public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway pour les Subnets Privés
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id # NAT dans un subnet public

  tags = {
    Name = "PFE-NATGateway"
  }
}

# Route Table pour Subnets Privés
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0" # Route Internet via le NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private-RouteTable"
  }
}

# Attacher les Subnets Privés à la Table de Routage Privée
resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Subnets pour la base de données
resource "aws_subnet" "db_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + 6) # Plage CIDR réservée aux DB
  availability_zone       = data.aws_availability_zones.available.names[count.index]    # Zones de disponibilité
  map_public_ip_on_launch = false                                                       # Pas d'IP publique pour les subnets de la DB

  tags = {
    Name = "DB-Subnet-${count.index + 1}"
  }
}

# Route Table privée pour les subnets DB
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  # route {
  #   cidr_block     = "0.0.0.0/0" # Accès Internet via le NAT Gateway
  #   nat_gateway_id = aws_nat_gateway.nat_gw.id
  # }

  tags = {
    Name = "DB-RouteTable"
  }
}

# Associer les subnets DB à la route table privée
resource "aws_route_table_association" "db_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db_route_table.id
}






# Default Security Group
resource "aws_security_group" "default_sg" {
  vpc_id = aws_vpc.main_vpc.id

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

  tags = {
    Name = "Default-SecurityGroup"
  }
}
