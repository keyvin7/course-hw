terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
}

resource "yandex_compute_disk" "boot-disk-server-1" {
  name     = "boot-disk-server-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_compute_disk" "boot-disk-server-2" {
  name     = "boot-disk-server-2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_compute_disk" "boot-disk-bastion" {
  name     = "boot-disk-bastion"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}


resource "yandex_compute_instance" "vm-server-1" {
  name = "vm-server-1"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-server-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-int-1.id
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-server-2" {
  name = "vm-server-2"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-server-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-int-2.id
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-int-1" {
  name           = "subnet1-int-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-int-2" {
  name           = "subnet1-int-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}


output "internal_ip_address_vm_server_1" {
  value = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_server_2" {
  value = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
}
