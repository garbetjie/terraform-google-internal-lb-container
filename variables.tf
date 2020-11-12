variable region {
  type = string
  description = "Name of the region in which to create resources."
}

variable image {
  type = string
  description = "Docker image to run."
}

variable ports {
  type = list(object({ protocol = string, port = number }))
  description = "Ports to expose from the container."
}

variable name_prefix {
  type = string
  default = null
  description = "Prefix to give to the names of all created resources. Trailing -'s are removed."
}

variable env {
  type = map(string)
  default = {}
  description = "Environment variables to inject into the running container."
}

variable machine_type {
  type = string
  default = "f1-micro"
  description = "GCE instance type to run the container on."
}

variable disk_type {
  type = string
  default = "pd-standard"
  description = "Disk type to create the GCE instances with."
}

variable disk_size {
  type = number
  default = 15
  description = "Disk size to create the GCE instances with."
}

variable tags {
  type = list(string)
  default = []
  description = "Network to add to the GCE instances."
}

variable labels {
  type = map(string)
  default = {}
  description = "Labels to apply to all created resources."
}

variable service_account_email {
  type = string
  default = null
  description = "Service account to run instances with."
}

variable replicas {
  type = number
  default = 1
  description = "Number of instances to ensure are running."
}

variable service_account_scopes {
  type = set(string)
  default = ["cloud-platform"]
  description = "Scopes to run service account with."
}

variable allow_global_access {
  type = bool
  default = true
  description = "Allow traffic to the load balancer from other regions."
}

variable all_ports {
  type = bool
  default = true
  description = "Expose all ports on the load balancer, rather than just the specified ones."
}

variable volumes {
  type = map(string)
  default = {}
  description = "Volumes to mount into the container."
}

variable run_scripts {
  type = string
  default = ""
  description = "Additional bash scripting to execute before running the image."
}

locals {
  name_prefix = var.name_prefix == null ? "i-lb-c-${random_id.default_prefix.hex}-${var.region}" : replace(var.name_prefix, "/-+$/", "")

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
        path = "/home/run.sh"
        permissions = "0755"
        content = templatefile("${path.module}/run.sh", {
          image = var.image,
          ports = var.ports
          volumes = var.volumes
          env = var.env
          run_scripts = var.run_scripts
        })
      }
    ]
    runcmd = ["sh /home/run.sh"]
  }
}
