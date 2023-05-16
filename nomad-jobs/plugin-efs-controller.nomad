job "plugin-aws-efs-controller" {
  datacenters = ["aws"]
  type = "system"

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-efs-csi-driver:v1.3.5"

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
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
