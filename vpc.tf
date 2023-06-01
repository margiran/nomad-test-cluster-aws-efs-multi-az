resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc-${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    "Name" = "my_igw-${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = var.subnets[count.index]
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "subnet-${var.availability_zones[count.index]}-${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
