provider "google" {
  credentials = "${file("terraform-admin.json")}"
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "ldap-server" {
  name         = "ldap-server"
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
      host        = google_compute_instance.ldap-server.network_interface.0.access_config.0.nat_ip
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
      host        = google_compute_instance.ldap-server.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    inline = [
      "chmod +x /tmp/conf/startup_server.sh",
      "cd /tmp/conf",
      "./startup_server.sh 12345"
    ]
  }
}

resource "google_compute_instance" "ldap-client" {
  name         = "ldap-client"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.ldap-client.network_interface.0.access_config.0.nat_ip
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      private_key = file("ssh/id_rsa")
    }
    inline = [
      "sudo yum -y install --disablerepo=google-cloud-sdk --disablerepo=google-compute-engine openldap-clients nss-pam-ldapd authconfig",
      "sudo authconfig --enableldap --enableldapauth --ldapserver=${google_compute_instance.ldap-server.network_interface.0.network_ip} --ldapbasedn=\"dc=devopslab,dc=com\" --enablemkhomedir --update"
    ]
  }

}

