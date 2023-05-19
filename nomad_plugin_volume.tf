provider "nomad" {
  address = "http://${aws_instance.nomad_server[0].public_ip}:4646"
}

resource "nomad_job" "csi-plugin-controller" {
  jobspec    = file("./nomad-jobs/plugin-efs-controller.nomad")
  depends_on = [aws_instance.nomad_client]
}

resource "nomad_job" "csi-plugin-node" {
  jobspec    = file("./nomad-jobs/plugin-efs-nodes.nomad")
  depends_on = [aws_instance.nomad_client]
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
  nomad_job.csi-plugin-controller]
}

resource "nomad_job" "using_volume" {
  jobspec = file("./nomad-jobs/mount_volume.nomad")

  depends_on = [nomad_volume.csi_volume_test]
}
