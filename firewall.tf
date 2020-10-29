//resource google_compute_firewall allowed_routes {
//  for_each = var.regions
//  name = "fluentd-${each.value}"
//  network = "default"
//  source_ranges = concat(data.google_compute_subnetwork.subnetworks[each.value].ip_cidr_range, var.additional_allowed_source_ranges)
//  target_tags = ["fluentd-${each.value}"]
//
//  allow {
//    protocol = "TCP"
//    ports = local.ports
//  }
//}

resource google_compute_firewall health_checks {
  name = local.prefix
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  network = "default"
  target_tags = ["${local.prefix}-fw"]

  allow {
    protocol = "TCP"
  }

  allow {
    protocol = "UDP"
  }
}
