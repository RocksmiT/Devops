
resource "google_compute_autoscaler" "default" {
  provider = google-beta

  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    metric {
      name                       = "pubsub.googleapis.com/subscription/num_undelivered_messages"
      filter                     = "resource.type = pubsub_subscription AND resource.label.subscription_id = our-subscription"
      single_instance_assignment = 65535
    }
  }
}

resource "google_compute_instance_template" "default" {
  provider = google-beta

  name           = "my-instance-template23"
  machine_type   = "n1-standard-1"
  can_ip_forward = false

  disk {
    source_image = "ubuntu-1804-lts"
  }

  network_interface {
    network = "my-network-11"
  }

  metadata = {
    metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask; sudo apt install curl; curl -4 icanhazip.com | tee ip.txt"
  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_firewall" "default" {
  provider = google-beta
  name    = "test-firewall"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_tags = ["web"]
}


resource "google_compute_http_health_check" "default" {
  provider = google-beta
  project = "careful-lock-271320"
  name         = "authentication-health-check"
  request_path = "/"

  timeout_sec        = 1
  check_interval_sec = 1
}


resource "google_compute_target_pool" "default" {
  provider = google-beta
  name = "instance-pool"

  instances = [
    "us-central1-a/my-instance-template1",

  ]

  health_checks = [
    google_compute_http_health_check.default.name,
  ]
}

resource "google_compute_instance_group_manager" "default" {
  provider = google-beta

  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.default.id]
  base_instance_name = "autoscaler-sample"
  named_port {
    name = "custom-http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.default.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_backend_service" "home" {
  provider   = google-beta
  name        = "login"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.self_link]
}
resource "google_compute_global_address" "default" {
  provider = google-beta
  name         = "terraform-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_url_map" "urlmap" {
  provider = google-beta
  name        = "urlmap"
  description = "a description"

  default_service = google_compute_backend_service.home.self_link

}

resource "google_compute_target_http_proxy" "http" {
  provider   = google-beta
  count   = var.enable_http ? 1 : 0
  name    = "terraform-http-proxy"
  url_map = google_compute_url_map.urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  count      = var.enable_http ? 1 : 0
  name       = "terraform-http-rule"
  target     = google_compute_target_http_proxy.http[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"

  depends_on = [google_compute_global_address.default]

  labels = var.custom_labels
}

module "gce-lb-fr" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-lb"
  region       = var.region
  name         = "group1-lb"
  service_port = 8080
  target_tags  = null
}

data "google_compute_image" "debian_9" {
  provider = google-beta

  family  = "debian-9"
  project = "debian-cloud"
}
