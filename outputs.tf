output address {
  value = google_compute_address.loadbalancer.address
}

output ports {
  value = var.ports
}

output labels {
  value = var.labels
}

output service_account_email {
  value = var.service_account_email
}

output tcp_ports {
  value = local.tcp_ports
}

output udp_ports {
  value = local.udp_ports
}
