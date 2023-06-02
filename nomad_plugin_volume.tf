# wait for Nomad 
# This code is being copied from the following repo https://github.com/hashicorp/nomad-autoscaler-demos/blob/main/cloud/demos/on-demand-batch/shared/terraform/modules/nomad-jobs/jobs.tf#L8
resource "null_resource" "wait_for_nomad_api" {
  provisioner "local-exec" {
    command = "while ! nomad server members > /dev/null 2>&1; do echo 'waiting for nomad api...'; sleep 10; done"
    environment = {
      NOMAD_ADDR = "http://${aws_instance.nomad_server[0].public_ip}:4646"
    }
  }
  depends_on = [aws_instance.nomad_client]
}

provider "nomad" {
  address = "http://${aws_instance.nomad_server[0].public_ip}:4646"
}

# resource "nomad_job" "csi-plugin-controller" {
#   jobspec    = file("./nomad-jobs/plugin-efs-controller.nomad")
#   depends_on = [aws_instance.nomad_client]
# }

resource "nomad_job" "csi-plugin-node" {
  jobspec    = file("./nomad-jobs/plugin-efs-nodes.nomad")
  depends_on = [aws_efs_file_system.efs-test, 
  null_resource.wait_for_nomad_api]
}

# wait for healhy csi plugin 
resource "null_resource" "wait_for_plugin" {
  provisioner "local-exec" {
    command = "while [[ 2 >  `nomad plugin status aws-efs0 | awk '/Nodes Healthy/ {print $4}'` ]]; do echo 'waiting for healthy csi nodes...'; sleep 5; done"

    environment = {
      NOMAD_ADDR = "http://${aws_instance.nomad_server[0].public_ip}:4646"
    }
  }
  depends_on = [nomad_job.csi-plugin-node]
}
resource "nomad_volume" "csi_volume_test" {
  type        = "csi"
  plugin_id   = "aws-efs0"
  volume_id   = "volume-test"
  name        = "volume-test"
  external_id = aws_efs_file_system.efs-test.id

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }
  depends_on = [aws_efs_file_system.efs-test,
  nomad_job.csi-plugin-node,null_resource.wait_for_plugin ]
}

resource "nomad_job" "using_volume" {
  jobspec = file("./nomad-jobs/mount_volume.nomad")

  depends_on = [null_resource.wait_for_plugin,nomad_volume.csi_volume_test]
}
