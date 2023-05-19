resource "aws_instance" "consul_server" {
  count                  = var.consul_server_count
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
  user_data = templatefile("${path.module}/cloudinit/cloudinit_consul_server.yaml", {
    consul_bootstrap_expect = var.consul_server_count,
    consul_retry_join       = "provider=aws tag_key=Name tag_value=consul_server_${random_pet.pet.id}_${terraform.workspace}"
  })
  tags = {
    Name = "consul_server_${random_pet.pet.id}_${terraform.workspace}"
  }
}
