resource google_compute_health_check load_balancer {
  name = "${local.prefix}-lb"
  check_interval_sec = 3
  timeout_sec = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = 22
  }

  dynamic "tcp_health_check" {
    for_each = local.tcp_ports
    content {
      port = tcp_health_check.value
    }
  }
}

resource google_compute_health_check instance_group {
  name = "${local.prefix}-ig"
  check_interval_sec = 10
  unhealthy_threshold = 3

  tcp_health_check {
    port = 22
  }

  dynamic "tcp_health_check" {
    for_each = local.tcp_ports
    content {
      port = tcp_health_check.value
    }
  }
}
