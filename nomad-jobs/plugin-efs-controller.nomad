job "plugin-aws-efs-controller" {
  datacenters = ["aws"]
  type = "system"

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-efs-csi-driver:latest"

        args = [
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--v=5",
      
        ]
        privileged = true
      }

      csi_plugin {
        id        = "aws-efs0"
        type      = "controller"
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
