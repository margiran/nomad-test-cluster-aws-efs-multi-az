resource "aws_efs_file_system" "efs-test" {
  creation_token   = "efs-test"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "efs_test_${random_pet.pet.id}_${terraform.workspace}"
  }
}

resource "aws_efs_mount_target" "efs-test-mount-target" {
  count           = length(aws_subnet.subnet)
  file_system_id  = aws_efs_file_system.efs-test.id
  subnet_id       = aws_subnet.subnet[count.index].id
  security_groups = ["${aws_security_group.efs-test-sg.id}"]
}

resource "aws_security_group" "efs-test-sg" {
  name   = "efs-test-sg-${random_pet.pet.id}_${terraform.workspace}"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    security_groups = ["${aws_security_group.instances.id}"]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }
}
