job "plugin-aws-efs-nodes" {
  datacenters = ["aws"]

  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"

  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-efs-csi-driver:latest"

        args = [
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        # node plugins must run as privileged jobs because they
        # mount disks to the host
         privileged = true
      }

      csi_plugin {
        id        = "aws-efs0"
        type      = "node"
        mount_dir = "/csi"
        health_timeout="2m"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
