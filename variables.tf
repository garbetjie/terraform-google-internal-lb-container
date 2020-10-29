variable region {
  type = string
}

variable image {
  type = string
}

variable prefix {
  type = string
  default = null
}

variable ports {
  type = list(object({ protocol = string, port = number }))
  default = []
}

variable machine_type {
  type = string
  default = "f1-micro"
}

variable disk_type {
  type = string
  default = "pd-standard"
}

variable disk_size {
  type = number
  default = 15
}

variable network_tags {
  type = set(string)
  default = []
}

variable labels {
  type = map(string)
  default = {}
}

variable service_account_email {
  type = string
  default = null
}

variable replicas {
  type = number
  default = 1
}

variable service_account_scopes {
  type = set(string)
  default = ["cloud-platform"]
}

variable allow_global_access {
  type = bool
  default = true
}

variable all_ports {
  type = bool
  default = true
}

locals {
  prefix = var.prefix == null ? "fluentd-${var.region}" : var.prefix

  tcp_ports = [
    for pair in var.ports:
      pair.port
    if lower(pair.protocol) == "tcp"
  ]

  udp_ports = [
    for pair in var.ports:
      pair.port
    if lower(pair.protocol) == "udp"
  ]

  cloud_init_config = {
    write_files = [
      {
        path = "/home/run_fluentd.sh"
        permissions = "0755"
        content = file("${path.module}/run_fluentd.sh")
      }
    ]
    runcmd = ["sh /home/run_fluentd.sh"]
  }
}
