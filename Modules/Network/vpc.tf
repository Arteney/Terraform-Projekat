resource "aws_db_subnet_group" "private" {
  name       = "positivetech-db-subnet-group-private-${var.ENV}"
  subnet_ids = [aws_subnet.PositiveTech-subnet-private-1.id, aws_subnet.PositiveTech-subnet-private-2.id]

  tags = {
    Name = "Private DB Subnet Group"
  }
}

resource "aws_internet_gateway" "PositiveTech" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table" "allow-outgoing-access" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PositiveTech.id
  }

  tags = {
    Name = "Route Table Allowing Outgoing Access"
  }
}

resource "aws_route_table_association" "PositiveTech-subnet-public" {
  subnet_id      = aws_subnet.PositiveTech-subnet-public.id
  route_table_id = aws_route_table.allow-outgoing-access.id
}

resource "aws_route_table_association" "PositiveTech-subnet-private-1" {
  subnet_id      = aws_subnet.PositiveTech-subnet-private-1.id
  route_table_id = aws_route_table.allow-outgoing-access.id
}

resource "aws_subnet" "PositiveTech-subnet-public" {
  availability_zone_id = "use1-az1"
  cidr_block           = "10.0.0.0/24"
  vpc_id               = aws_vpc.main-vpc.id

  tags = {
    Name = "Subnet (Public)"
  }
}

resource "aws_subnet" "PositiveTech-subnet-private-1" {
  availability_zone_id = "use1-az1"
  cidr_block           = "10.0.1.0/24"
  vpc_id               = aws_vpc.main-vpc.id

  tags = {
    Name = "Subnet (Private 1)"
  }
}

resource "aws_subnet" "PositiveTech-subnet-private-2" {
  availability_zone_id = "use1-az2"
  cidr_block           = "10.0.2.0/24"
  vpc_id               = aws_vpc.main-vpc.id

  tags = {
    Name = "Subnet (Private 2)"
  }
}

resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.ENV}"
  }
}

