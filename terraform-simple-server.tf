# Terraform IONOS simple server setup

terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
    }
  }
}

provider "ionoscloud" {
  username = var.ionos_username
  password = var.ionos_password
}

resource "ionoscloud_datacenter" "terra-bash-script" {
  location    = "us/ewr"
  name        = "terraform-wp1"
  description = "terraform sandbox bash script"
}

resource "ionoscloud_lan" "terraform-lan-1" {
  datacenter_id = ionoscloud_datacenter.terra-bash-script.id
  name          = "terraform-lan-1"
  public        = true
}

resource "ionoscloud_server" "terraform-wp1" {
  name              = "terraform-wp1"
  datacenter_id     = ionoscloud_datacenter.terra-bash-script.id
  cores             = 2
  ram               = 4 * 1024
  cpu_family        = "AMD_OPTERON"
  availability_zone = "AUTO"
  image_name        = "ubuntu"
  # path below is the path to the public key already created you want to copy to the server instance, enter your local path
  ssh_key_path = [
    "/home/home/.ssh/id_ed25519.pub",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.primary_ip
  }

  nic {
    lan             = ionoscloud_lan.terraform-lan-1.id
    dhcp            = true
    firewall_active = false
    name            = "wan"
  }

  volume {
    name      = "terraform-wp1-vol1"
    size      = 50
    disk_type = "HDD"
  }

  provisioner "file" {
    source      = "hello.txt"
    destination = "/tmp/hello.txt"
  }
  
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
