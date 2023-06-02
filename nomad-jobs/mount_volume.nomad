job "test-csi" {
  datacenters = ["aws"]
  type        = "service"
  priority    = 50

  group "test-group" {
    count = 2
    
    network {
      port "redis" {
        to = 6379
      }
    }
    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    restart {
      attempts = 3
      delay    = "60s"
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
        image   = "redis"
        ports   = ["redis"]
        volumes = ["local/redis.conf:/usr/local/etc/redis/redis.conf"]
        command = "redis-server"
        args    = ["/usr/local/etc/redis/redis.conf"]
      }
      template {
        data        = <<EOF
appendonly yes 
save 900 1
save 300 10
save 60 10000
EOF
        destination = "local/redis.conf"
      }
      resources {
        cpu    = 300
        memory = 512
      }

    }
  }
}
