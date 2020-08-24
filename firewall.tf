resource google_compute_firewall allowed_routes {
  for_each = var.regions
  name = "fluentd-${each.value}"
  network = "default"
  source_ranges = concat(["10.128.0.0/9"], var.additional_allowed_source_ranges)
  target_tags = ["fluentd-${each.value}"]

  allow {
    protocol = "TCP"
    ports = local.ports
  }
}
