terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}



resource "aws_subnet" "subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name = "subnet-${var.availability_zones[count.index]}-${random_pet.pet.id}_${terraform.workspace}"
  }
}
# resource "tls_private_key" "private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "aws_key_pair" "my_key" {
  key_name = "key-terraform-${random_pet.pet.id}_${terraform.workspace}"

  public_key = file("~/.ssh/key_pair.pub")
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

# the public_ip of my gw
locals {
  myip = "${data.http.myip.response_body}/32"
}

resource "random_pet" "pet" {
  length = 1
}

resource "aws_security_group" "instances" {
  name   = "${var.security_group_name}-${random_pet.pet.id}_${terraform.workspace}"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  ingress {
    from_port   = 3000
    to_port     = 3010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  ingress {
    from_port   = 9000
    to_port     = 9010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }

  # opening port used by consul
  ingress {
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }

  # opening port used by consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }

  # opening port used by nomad agents 
  ingress {
    from_port   = 4646
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  # opening port used by nomad agents 
  ingress {
    from_port   = 4646
    to_port     = 4648
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  # opening port 22 to be able to ssh to the instances
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  # netdata monitoring
  ingress {
    description = "netdata from internet"
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", local.myip]
  }
  # provide internet access to the instance (install packages, etc)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "nomad_server" {
  count                  = var.nomad_server_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.server_instance_type
  vpc_security_group_ids = [aws_security_group.instances.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.subnet[0].id

  root_block_device {
    volume_size = 100
    volume_type = "io1"
    iops        = 1000
  }

  user_data = templatefile("${path.module}/cloudinit/cloudinit_nomad_server.yaml", {
    consul_retry_join      = "provider=aws tag_key=Name tag_value=consul_server_${random_pet.pet.id}_${terraform.workspace}",
    nomad_bootstrap_expect = var.nomad_server_count,
    nomad_retry_join       = "provider=aws tag_key=Name tag_value=nomad_server_${random_pet.pet.id}_${terraform.workspace}"
  })
  tags = {
    Name = "nomad_server_${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_instance" "nomad_client" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.client_instance_type
  vpc_security_group_ids = [aws_security_group.instances.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.subnet[count.index].id

  root_block_device {
    volume_size = 100
    volume_type = "io1"
    iops        = 1000
  }
  user_data = templatefile("${path.module}/cloudinit/cloudinit_nomad_client.yaml", {
    consul_retry_join = "provider=aws tag_key=Name tag_value=consul_server_${random_pet.pet.id}_${terraform.workspace}",
    nomad_retry_join  = "provider=aws tag_key=Name tag_value=nomad_server_${random_pet.pet.id}_${terraform.workspace}"
  })
  tags = {
    Name = "nomad_client_${random_pet.pet.id}_${terraform.workspace}"
  }
}

