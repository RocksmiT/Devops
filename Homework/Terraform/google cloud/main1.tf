
resource "random_id" "instance_id2" {
 byte_length = 8
}
// A single Google Cloud Engine instance
resource "google_compute_instance" "default2" {
 name         = "flask-vm-${random_id.instance_id2.hex}"
 machine_type = "n1-standard-1"
 zone         = "us-central1-a"
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }
// Make sure flask is installed on all new instances for later steps
metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask; sudo apt install curl; curl -4 icanhazip.com | tee ip.txt"
 network_interface {
   network = "my-network-11"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }
metadata = {
   ssh-keys = "nevermind:${file("~/id_rsa.pub")}"
 }
}
