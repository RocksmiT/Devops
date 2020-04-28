resource "google_compute_global_address" "paas-monitor" {
  name = "paas-monitor"
}

resource "google_compute_global_forwarding_rule" "paas-monitor" {
  name       = "paas-monitor-port-80"
  ip_address = "google_compute_global_address.paas-monitor.address"
  port_range = "80"
  target     = "google_compute_target_http_proxy.paas-monitor.self_link"
}

resource "google_compute_target_http_proxy" "paas-monitor" {
  name    = "paas-monitor"
  url_map = "google_compute_url_map.paas-monitor.self_link"
}

resource "google_compute_url_map" "paas-monitor" {
  name        = "paas-monitor"
  default_service = "google_compute_backend_service.paas-monitor.self_link"
}

resource "google_compute_backend_service" "paas-monitor" {
  name             = "paas-monitor-backend"
  protocol         = "HTTP"
  port_name        = "paas-monitor"
  timeout_sec      = 10
  session_affinity = "NONE"

  backend {
    group = "google_compute_instance_group_manager.default.instance_group"
  }


resource "google_compute_http_health_check" "paas-monitor" {
  name         = "paas-monitor-123"
  request_path = "/health"

  timeout_sec        = 5
  check_interval_sec = 5
  port               = 1337

  lifecycle {
    create_before_destroy = true
  }
}

}

resource "google_compute_firewall" "paas-monitor" {
  ## firewall rules enabling the load balancer health checks
  name    = "paas-monitor-firewall"
  network = "default"

  description = "allow Google health checks and network load balancers access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1337"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["paas-monitor"]
}

resource "google_compute_region_instance_group_manager" "paas-monitor" {
  name = "paas-monitor-2"
  region = "us-central1"

  base_instance_name = "paas-monitor-1"
  instance_template  = "$google_compute_instance_template.paas-monitor.self_link"

  version {
    name              = "v1"
    instance_template = "$google_compute_instance_template.paas-monitor.self_link"
  }

  named_port {
    name = "paas-monitor"
    port = 1337
  }

  auto_healing_policies {
    health_check      = "google_compute_http_health_check.paas-monitor.self_link"
    initial_delay_sec = 30
  }

  update_strategy = "ROLLING_UPDATE"
}
