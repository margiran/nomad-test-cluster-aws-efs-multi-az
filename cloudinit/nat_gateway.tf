resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    "Name" = "nat_eip-${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count                   = length(aws_subnet.subnet)
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet[count.index].id  

  tags = {
    "Name" = "nat_gateway-${var.availability_zones[count.index]}-${random_pet.pet.id}_${terraform.workspace}"
  }

  depends_on = [aws_internet_gateway.igw]
}

