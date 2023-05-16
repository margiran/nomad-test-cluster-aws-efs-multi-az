resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
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

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }

# }
# resource "aws_route_table_association" "nat_association" {
#   subnet_id      = aws_subnet.private-us-east-2a.id
#   route_table_id = aws_route_table.private_route_table.id
# }

resource "aws_route_table_association" "public_association" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# resource "aws_route_table_association" "public_b_association" {
#   subnet_id      = aws_subnet.public-us-east-2b.id
#   route_table_id = aws_route_table.public_route_table.id
# }