terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.85"
    }
  }

  required_version = ">= 1.5.0"
}


provider "yandex" {
  service_account_key_file = var.yc_service_account_key_file

  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}


data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}


data "yandex_vpc_network" "default" {
  name = "default"
}


data "yandex_vpc_subnet" "default" {
  name = "default-${var.yc_zone}"
}



################################################################################
# DATABASE
################################################################################


resource "yandex_mdb_postgresql_cluster" "app_db" {

  name = "devops-db-cluster"

  environment = "PRESTABLE"

  network_id = data.yandex_vpc_network.default.id


  config {

    version = "15"


    resources {

      resource_preset_id = "s2.micro"

      disk_size = 20

      disk_type_id = "network-hdd"

    }

  }


  host {

    zone = var.yc_zone

    subnet_id = data.yandex_vpc_subnet.default.id

    assign_public_ip = false

  }

}

resource "yandex_mdb_postgresql_database" "app_db" {

  cluster_id = yandex_mdb_postgresql_cluster.app_db.id

  name = "db1"

}


resource "yandex_mdb_postgresql_user" "app_user" {

  cluster_id = yandex_mdb_postgresql_cluster.app_db.id

  name     = "user1"
  password = var.db_password


  depends_on = [
    yandex_mdb_postgresql_database.app_db
  ]

}


################################################################################
# APPLICATION VM
################################################################################


resource "yandex_compute_instance" "app_vm" {

  name = "devops-app-vm"


  platform_id = "standard-v3"


  zone = var.yc_zone



  resources {

    cores = 2

    memory = 2

    core_fraction = 20

  }



  boot_disk {

    initialize_params {

      image_id = data.yandex_compute_image.ubuntu.id

      size = 20

    }

  }



  network_interface {

    subnet_id = data.yandex_vpc_subnet.default.id

    nat = true

  }



  metadata = {


    ssh-keys = "ubuntu:${var.ssh_public_key}"



    user-data = <<-EOF

      #cloud-config


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

        - systemctl enable docker

        - systemctl start docker

        - usermod -aG docker ubuntu

    EOF

  }



  depends_on = [

    yandex_mdb_postgresql_user.app_user

  ]

}




################################################################################
# MONITORING VM
################################################################################


resource "yandex_compute_instance" "monitoring_vm" {


  name = "devops-monitoring-vm"



  platform_id = "standard-v3"



  zone = var.yc_zone



  resources {

    cores = 2

    memory = 2

    core_fraction = 20

  }



  boot_disk {

    initialize_params {

      image_id = data.yandex_compute_image.ubuntu.id

      size = 20

    }

  }



  network_interface {

    subnet_id = data.yandex_vpc_subnet.default.id

    nat = true

  }




  metadata = {


    ssh-keys = "ubuntu:${var.ssh_public_key}"



    user-data = <<-EOF

      #cloud-config


      packages:

        - docker.io

        - docker-compose-v2



      runcmd:

        - systemctl enable docker

        - systemctl start docker

        - usermod -aG docker ubuntu

        - mkdir -p /opt/monitoring

    EOF

  }



  depends_on = [

    yandex_compute_instance.app_vm

  ]

}




################################################################################
# OUTPUTS
################################################################################


output "app_vm_ip" {

  value = yandex_compute_instance.app_vm.network_interface[0].nat_ip_address

}



output "monitoring_vm_ip" {

  value = yandex_compute_instance.monitoring_vm.network_interface[0].nat_ip_address

}



output "db_fqdn" {

  value = yandex_mdb_postgresql_cluster.app_db.host[0].fqdn

}