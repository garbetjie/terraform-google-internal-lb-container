resource random_id default_prefix {
  byte_length = 2
}

resource google_compute_address loadbalancer {
  name = local.name_prefix
  region = var.region
  address_type = "INTERNAL"
  purpose = "SHARED_LOADBALANCER_VIP"
  provider = google-beta
}

resource google_compute_forwarding_rule tcp {
  count = length(local.tcp_ports) > 0 ? 1 : 0

  name = "${local.name_prefix}-tcp"
  region = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service = google_compute_region_backend_service.tcp[0].self_link
  all_ports = var.all_ports
  network = "default"
  ip_address = google_compute_address.loadbalancer.address
  allow_global_access = var.allow_global_access
}

resource google_compute_forwarding_rule udp {
  count = length(local.udp_ports) > 0 ? 1 : 0

  name = "${local.name_prefix}-udp"
  region = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service = google_compute_region_backend_service.udp[0].self_link
  all_ports = var.all_ports
  network = "default"
  ip_address = google_compute_address.loadbalancer.address
  ip_protocol = "UDP"
  allow_global_access = var.allow_global_access
}

resource google_compute_region_backend_service tcp {
  count = length(local.tcp_ports) > 0 ? 1 : 0

  name = "${local.name_prefix}-tcp"
  protocol = "TCP"
  region = var.region
  health_checks = [google_compute_health_check.load_balancer.self_link]
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_region_instance_group_manager.fluentd.instance_group
  }
}

resource google_compute_region_backend_service udp {
  count = length(local.udp_ports) > 0 ? 1 : 0

  name = "${local.name_prefix}-udp"
  protocol = "UDP"
  region = var.region
  load_balancing_scheme = "INTERNAL"
  health_checks = [google_compute_health_check.load_balancer.self_link]

  backend {
    group = google_compute_region_instance_group_manager.fluentd.instance_group
  }
}

resource google_compute_region_instance_group_manager fluentd {
  base_instance_name = local.name_prefix
  name = local.name_prefix
  target_size = var.replicas
  region = var.region

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    instance_redistribution_type = "PROACTIVE"
    max_surge_fixed = length(data.google_compute_zones.available_zones.names)
    max_unavailable_fixed = 0
    min_ready_sec = 60
  }

  auto_healing_policies {
    health_check = google_compute_health_check.instance_group.self_link
    initial_delay_sec = 60
  }

  version {
    instance_template = google_compute_instance_template.template.self_link
  }
}

resource google_compute_instance_template template {
  name_prefix = "${local.name_prefix}-"
  machine_type = var.machine_type
  labels = var.labels
  region = var.region
  tags = distinct(concat(var.tags, ["${local.name_prefix}-fw"]))

  metadata = {
    "user-data" = "#cloud-config\n${yamlencode(local.cloud_init_config)}"
  }

  network_interface {
    network = "default"
  }

  dynamic "service_account" {
    for_each = var.service_account_email != null ? [var.service_account_email] : []
    content {
      email = service_account.value
      scopes = var.service_account_scopes
    }
  }

  disk {
    auto_delete = true
    boot = true
    disk_size_gb = var.disk_size
    disk_type = var.disk_type
    labels = var.labels
    source_image = "cos-cloud/cos-stable"
  }

  lifecycle {
    create_before_destroy = true
  }
}
