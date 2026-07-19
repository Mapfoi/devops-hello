terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.85"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.yc_service_account_key_file
  
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Получаем актуальный ID образа Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_vpc_network" "app_network" {
  name = "devops-app-network"
}

resource "yandex_vpc_subnet" "app_subnet" {
  name           = "devops-app-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_mdb_postgresql_cluster" "app_db" {
  name        = "devops-db-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.app_network.id

  config {
    version = "15"
    resources {
      resource_preset_id = "s2.micro"
      disk_size          = 20
      disk_type_id       = "network-hdd"
    }
  }

  host {
    zone      = var.yc_zone
    subnet_id = yandex_vpc_subnet.app_subnet.id
    assign_public_ip = false
  }
}

resource "yandex_compute_instance" "app_vm" {
  name        = "devops-app-vm"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.app_subnet.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
      
      write_files:
        - path: /etc/environment
          content: |
            DB_HOST=${yandex_mdb_postgresql_cluster.app_db.host[0].fqdn}
            DB_PORT=6432
            DB_NAME=db1
            DB_USER=user1
            DB_PASSWORD=${var.db_password}
      
      packages:
        - docker.io
        - docker-compose-v2
      
      runcmd:
        - [ systemctl, start, docker ]
        - [ systemctl, enable, docker ]
        - [ usermod, -aG, docker, ubuntu ]
    EOF
  }

  depends_on = [yandex_mdb_postgresql_cluster.app_db]
}

resource "yandex_compute_instance" "monitoring_vm" {
  name        = "devops-monitoring-vm"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.app_subnet.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
      
      packages:
        - docker.io
        - docker-compose-v2
      
      runcmd:
        - [ systemctl, start, docker ]
        - [ systemctl, enable, docker ]
        - [ usermod, -aG, docker, ubuntu ]
        - [ mkdir, -p, /opt/monitoring ]
    EOF
  }
}

output "app_vm_ip" {
  value = yandex_compute_instance.app_vm.network_interface.0.nat_ip_address
}

output "monitoring_vm_ip" {
  value = yandex_compute_instance.monitoring_vm.network_interface.0.nat_ip_address
}

output "db_fqdn" {
  value = yandex_mdb_postgresql_cluster.app_db.host[0].fqdn
}
