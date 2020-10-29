resource google_compute_firewall health_checks {
  name = local.name_prefix
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  network = "default"
  target_tags = ["${local.name_prefix}-fw"]

  allow {
    protocol = "TCP"
    ports = concat([22], local.tcp_ports)
  }

  dynamic "allow" {
    for_each = length(local.udp_ports) > 0 ? [local.udp_ports] : []

    content {
      protocol = "UDP"
      ports = allow.value
    }
  }
}
