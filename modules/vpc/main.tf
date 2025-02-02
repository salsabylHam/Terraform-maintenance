# Définir le VPC avec une plage CIDR /16
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr # Plage CIDR principale
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main-VPC"
  }
}

# Zones de disponibilité disponibles
data "aws_availability_zones" "available" {}

# Subnets publics (3 sous-réseaux)
resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, count.index) # Génère une plage pour chaque sous-réseau public
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

# Subnets privés (3 sous-réseaux)
resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, count.index + 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}

# Subnets pour la base de données (2 sous-réseaux)
resource "aws_subnet" "db_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, count.index + 6)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "DB-Subnet-${count.index + 1}"
  }
}

# Route Table pour DB (Loopback uniquement)
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = aws_vpc.main_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "DB-RouteTable"
  }
}

# Association des subnets DB à leur table de routage
resource "aws_route_table_association" "db_subnet_association" {
  count          = length(aws_subnet.db_subnets)
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db_route_table.id
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main-InternetGateway"
  }
}

# Route Table pour Subnets Publics
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RouteTable"
  }
}

# Association des subnets publics à leur table de routage
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway et EIP pour les subnets privés
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Main-NATGateway"
  }
}

# Route Table pour Subnets Privés
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private-RouteTable"
  }
}

# Association des subnets privés à leur table de routage
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}


