data google_compute_zones available_zones {
  for_each = var.regions
  region = each.value
}

resource random_shuffle available_zones {
  for_each = var.regions
  input = data.google_compute_zones.available_zones[each.key].names
  result_count = 1

  keepers = {
    region = each.value
  }
}

resource random_id fluentd_instance_name_suffix {
  for_each = var.regions
  byte_length = 2

  keepers = {
    region = each.value
    disk_size = var.disk_size
    disk_type = var.disk_type
    machine_type = var.machine_type
    cloud_init_config = local.cloud_init_config
    service_account_email = google_service_account.fluentd.email
  }
}

resource google_compute_instance fluentd {
  for_each = var.regions
  name = "fluentd-${each.value}-${random_id.fluentd_instance_name_suffix[each.key].hex}"
  machine_type = random_id.fluentd_instance_name_suffix[each.key].keepers.machine_type
  zone = local.regions_to_zones[each.value]
  tags = ["requires-nat-${each.value}", "fluentd-${each.value}"]

  service_account {
    email = random_id.fluentd_instance_name_suffix[each.key].keepers.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    "user-data" = "#cloud-config\n${random_id.fluentd_instance_name_suffix[each.key].keepers.cloud_init_config}"
  }

  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size = random_id.fluentd_instance_name_suffix[each.key].keepers.disk_size
      type = random_id.fluentd_instance_name_suffix[each.key].keepers.disk_type
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource google_compute_instance_group fluentd {
  for_each = var.regions
  name = "fluentd"
  zone = local.regions_to_zones[each.value]
  instances = [google_compute_instance.fluentd[each.key].self_link]
}

resource google_compute_address load_balancer {
  for_each = var.regions
  name = "fluentd-load-balancer"
  description = "IP address for internal load balancer for forwarding logs to BigQuery"
  address_type = "INTERNAL"
  region = each.value
}

resource google_compute_forwarding_rule fluentd {
  for_each = var.regions
  name = "fluentd"
  region = each.value
  load_balancing_scheme = "INTERNAL"
  backend_service = google_compute_region_backend_service.fluentd[each.value].self_link
  all_ports = true
  network = "default"
  ip_address = google_compute_address.load_balancer[each.key].address
}

resource google_compute_region_backend_service fluentd {
  for_each = var.regions
  name = "fluentd"
  protocol = "TCP"
  health_checks = [google_compute_health_check.fluentd.self_link]
  region = each.value
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_instance_group.fluentd[each.key].self_link
  }
}

resource google_compute_health_check fluentd {
  name = "fluentd"

  dynamic "tcp_health_check" {
    for_each = local.ports
    content {
      port = tcp_health_check.value
    }
  }
}

output load_balancer_addresses {
  value = {
  for key, value in var.regions:
  value => google_compute_address.load_balancer[value].address
  }
}
