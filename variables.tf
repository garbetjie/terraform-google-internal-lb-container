variable regions {
  type = set(string)
}

variable additional_allowed_source_ranges {
  type = list(string)
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

locals {
  regions_to_zones = {
    for index, value in var.regions:
      value => random_shuffle.available_zones[index].result[0]
  }

  ports = [20001]

  cloud_init_config = yamlencode({
    write_files = [
      {
        path = "/home/run_fluentd.sh"
        permissions = "0755"
        content = file("${path.module}/run_fluentd.sh")
      }
    ]
    runcmd = ["sh /home/run_fluentd.sh"]
  })
}
