# output "private_key_pem" {
#   description = "The private key (save this in a .pem file) for ssh to instances"
#   value       = tls_private_key.private_key.private_key_pem
#   sensitive   = true
# }
output "consul_server_public_ip" {
  description = "The public IP of the EC2 Instance "
  value       = aws_instance.consul_server[*].public_ip
}

output "consul_server_private_ip" {
  description = "The private IP of the EC2 Instance "
  value       = aws_instance.consul_server[*].private_ip
}

output "nomad_server_public_ip" {
  description = "The public IP of the EC2 Instance "
  value       = aws_instance.nomad_server[*].public_ip
}

output "nomad_server_private_ip" {
  description = "The private IP of the EC2 Instance "
  value       = aws_instance.nomad_server[*].private_ip
}

output "client_public_ip" {
  description = "The public IP of the EC2 Instance client "
  value       = [aws_instance.nomad_client[*].public_ip]
}

output "client_private_ip" {
  description = "The private IP of the EC2 Instance client"
  value       = [aws_instance.nomad_client[*].private_ip]
}

output "ssh_consul_server_public_ip" {
  description = "Command for ssh to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.consul_server : "ssh ubuntu@${k.public_ip} -i ~/.ssh/key_pair"
  ]
}

output "http_consul_server_public_ip" {
  description = "Command for http to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.consul_server : "http://${k.public_ip}:8500"
  ]
}

output "consul_addr_consul_server_public_ip" {
  description = "Command for http to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.consul_server : "export CONSUL_ADDR=http://${k.public_ip}:8500"
  ]
}

output "netdata_consul_server_public_ip" {
  description = "Command for netdata to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.consul_server : "http://${k.public_ip}:19999"
  ]
}

output "ssh_nomad_server_public_ip" {
  description = "Command for ssh to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_server : "ssh ubuntu@${k.public_ip} -i ~/.ssh/key_pair"
  ]
}

output "http_nomad_server_public_ip" {
  description = "Command for http to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_server : "http://${k.public_ip}:4646"
  ]
}

output "nomad_addr_nomad_server_public_ip" {
  description = "Command for http to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_server : "export NOMAD_ADDR=http://${k.public_ip}:4646"
  ]
}

output "netdata_nomad_server_public_ip" {
  description = "Command for netdata to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_server : "http://${k.public_ip}:19999"
  ]
}

output "ssh_client_public_ip" {
  description = "Command for ssh to the Client public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_client : "ssh ubuntu@${k.public_ip} -i ~/.ssh/key_pair"
  ]
}

output "netdata_client_public_ip" {
  description = "Command for netdata to the Server public IP of the EC2 Instance"
  value = [
    for k in aws_instance.nomad_client : "http://${k.public_ip}:19999"
  ]
}

output "efs_mount_target_dns_name" {
  description = "efs"
  # value = "${aws_efs_mount_target.efs-mt-example.dns_name }"
  value = [
    for k in aws_efs_mount_target.efs-test-mount-target : "http://${k.dns_name}"
  ]
}

output "efs_file_system_dns_name" {
  description = "efs"
  value       = aws_efs_file_system.efs-test.id

}