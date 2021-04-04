provider "google" {
  credentials = "${file("terraform-admin.json")}"
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "el-server" {
  name         = "el-server"
  machine_type = var.machine_type

  tags = ["ldap-server"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.type
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("ssh/id_rsa.pub")}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.el-server.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    source      = "./sh"
    destination = "/tmp/sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.el-server.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    inline = [
      "chmod +x /tmp/sh/*sh",
      "cd /tmp/sh",
      "./Server.sh",
    ]
  }
}
