resource google_compute_health_check load_balancer {
  name = "${local.name_prefix}-lb"
  check_interval_sec = 3
  timeout_sec = 2
  unhealthy_threshold = 2
  healthy_threshold = 1

  tcp_health_check {
    port = length(local.tcp_ports) > 0 ? local.tcp_ports[0] : 22
  }
}

resource google_compute_health_check instance_group {
  name = "${local.name_prefix}-ig"
  check_interval_sec = 30
  unhealthy_threshold = 3
  healthy_threshold = 1

  tcp_health_check {
    port = length(local.tcp_ports) > 0 ? local.tcp_ports[0] : 22
  }
}
