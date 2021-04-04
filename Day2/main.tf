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
    source      = "./conf"
    destination = "/tmp/conf"
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
      "chmod +x /tmp/conf/*sh",
      "cd /tmp/conf",
      "./server.sh",
    ]
  }
}

resource "google_compute_instance" "tomcat" {
  name         = "tomcat"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.type
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("ssh/id_rsa.pub")}"
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.tomcat.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    source      = "./conf"
    destination = "/tmp/conf"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.tomcat.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    inline = [
      "chmod +x /tmp/conf/*sh",
      "cd /tmp/conf",
      "./tomcat.sh ${google_compute_instance.el-server.network_interface.0.network_ip}",
      ]
  }

}
