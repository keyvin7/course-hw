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
    nat       = true
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
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-bastion" {
  name = "vm-bastion"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-bastion.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-ext.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-int-1" {
  name           = "subnet-int-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-int-2" {
  name           = "subnet-int-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "subnet-ext" {
  name           = "subnet-ext"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

locals {
  bastion_name        = yandex_compute_instance.vm-bastion.name
  bastion_external_ip = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
  bastion_internal_ip = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
  bastion_zone        = yandex_compute_instance.vm-bastion.zone
  vm_1_name           = yandex_compute_instance.vm-server-1.name
  vm_1_external_ip    = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
  vm_1_internal_ip    = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
  vm_1_zone           = yandex_compute_instance.vm-server-1.zone
  vm_2_name           = yandex_compute_instance.vm-server-2.name
  vm_2_external_ip    = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
  vm_2_internal_ip    = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
  vm_2_zone           = yandex_compute_instance.vm-server-2.zone
}

output "ansible_inventory" {
  value = templatefile("${path.module}/ansible_inventory.tpl", {
    bastion_name        = yandex_compute_instance.vm-bastion.name
    bastion_external_ip = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
    bastion_internal_ip = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
    bastion_zone        = yandex_compute_instance.vm-bastion.zone
    vm_1_name           = yandex_compute_instance.vm-server-1.name
    vm_1_external_ip    = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
    vm_1_internal_ip    = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
    vm_1_zone           = yandex_compute_instance.vm-server-1.zone
    vm_2_name           = yandex_compute_instance.vm-server-2.name
    vm_2_external_ip    = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
    vm_2_internal_ip    = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
    vm_2_zone           = yandex_compute_instance.vm-server-2.zone
  })
  description = "Содержимое для Ansible inventory файла"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible_inventory.tpl", {
    bastion_name        = yandex_compute_instance.vm-bastion.name
    bastion_external_ip = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
    bastion_internal_ip = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
    bastion_zone        = yandex_compute_instance.vm-bastion.zone
    vm_1_name           = yandex_compute_instance.vm-server-1.name
    vm_1_external_ip    = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
    vm_1_internal_ip    = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
    vm_1_zone           = yandex_compute_instance.vm-server-1.zone
    vm_2_name           = yandex_compute_instance.vm-server-2.name
    vm_2_external_ip    = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
    vm_2_internal_ip    = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
    vm_2_zone           = yandex_compute_instance.vm-server-2.zone
  })
  filename = "${path.module}/terraform_generated.ini"

  depends_on = [
    yandex_compute_instance.vm-bastion,
    yandex_compute_instance.vm-server-1,
    yandex_compute_instance.vm-server-2
  ]
}
