resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "n1-standard-1"

  network_interface {
    network = "my-network-11"
    access_config {
    }
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }
}

resource "google_compute_instance_group_manager" "webservers" {
  name = "my-webservers"
  base_instance_name = "webserver"
  version {
    instance_template = "{google_compute_instance_template.webserver.self_link}"
  }
  zone               = "us-west1-a"
  target_size        = 3
  named_port {
    name = "http"
    port = 80
  }
}

