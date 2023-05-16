job "test-csi" {
  datacenters = ["aws"]
  type        = "service"
  priority    = 50

  # constraint {
  #   attribute = "${node.unique.name}"
  #   value     = "dev-nomad-privilege-client-swift-2"
  # }

  group "test-group" {
    count = 2

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    restart {
      attempts = 3
      delay    = "30s"
    }

    volume "efs-volume" {
      type            = "csi"
      read_only       = false
      source          = "volume-test"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "volumetest" {
      driver = "docker"

      volume_mount {
        volume      = "efs-volume"
        destination = "/data"
        read_only   = false
      }

      config {
        image = "ubuntu:latest"
        args = [
          "sleep", "2d"
        ]
      }
      
      resources {
        cpu    = 300
        memory = 512
      }

    }
  }
}
