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

resource "yandex_compute_disk" "boot-disk-prometheus" {
  name     = "boot-disk-prometheus"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_compute_disk" "boot-disk-grafana" {
  name     = "boot-disk-boot-disk-grafana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_compute_disk" "boot-disk-elasticsearch" {
  name     = "boot-disk-elasticsearch"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_compute_disk" "boot-disk-kibana" {
  name     = "boot-disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "50"
  image_id = "fd888dplf7gt1nguheht"
}

resource "yandex_vpc_security_group" "sg_bastion" {
  name        = "sg_bastion"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "rule2 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "sg_vm" {
  name        = "sg_vm"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.30.34/32", "130.193.46.85/32"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "rule2 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_compute_snapshot_schedule" "default" {
  name = "daily-backup"

  schedule_policy {
    expression = "10 16 * * *" # Каждый день в 19:10 по московскому времени
  }

  snapshot_count = 7 # Хранить последние 7 снимков для каждого диска

  snapshot_spec {
    description = "Ежедневный снимок"
  }

  disk_ids = ["fhmotqip5blkj94eu66i", "epdqhlk2oqbijkl0uqqb"]
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
    security_group_ids = [ yandex_vpc_security_group.sg_vm.id ]
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
    security_group_ids = [ yandex_vpc_security_group.sg_vm.id ]
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
    security_group_ids = [ yandex_vpc_security_group.sg_bastion.id ]
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-prometheus" {
  name = "vm-prometheus"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-prometheus.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-int-prometheus.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-grafana" {
  name = "vm-grafana"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-grafana.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-ext-grafana.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-elasticsearch" {
  name = "vm-elasticsearch"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-elasticsearch.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-int-elasticsearch.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/chupin/course-hw/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-kibana" {
  name = "vm-kibana"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-kibana.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-int-kibana.id
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

resource "yandex_vpc_subnet" "subnet-int-prometheus" {
  name           = "subnet-int-prometheus"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.50.0/24"]
}

resource "yandex_vpc_subnet" "subnet-ext-grafana" {
  name           = "subnet-int-grafana"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.60.0/24"]
}

resource "yandex_vpc_subnet" "public-subnet-alb" {
  name           = "public-subnet-alb"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.40.0/24"]
}

resource "yandex_vpc_subnet" "subnet-int-elasticsearch" {
  name           = "subnet-int-elasticsearch"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.80.0/24"]
}

resource "yandex_vpc_subnet" "subnet-int-kibana" {
  name           = "subnet-int-kibana"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.70.0/24"]
}

resource "yandex_alb_target_group" "web-server-target-group" {
  name = "web-server-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.subnet-int-1.id
    ip_address = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-int-2.id
    ip_address = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web-server-backend-group" {
  name = "web-server-backend-group"

  http_backend {
    name             = "web-server-http-backend"
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.web-server-target-group.id}"]

    healthcheck {
      timeout          = "5s"
      interval         = "5s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web-router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web-virtual-host" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id # Ссылка на HTTP Router
  authority      = ["*"]                                # Обрабатывать запросы с любого домена

  route {
    name = "root-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-server-backend-group.id # Ссылка на Backend Group
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web-server-balancer" {
  name       = "web-server-balancer"
  network_id = yandex_vpc_network.network-1.id # Ссылка на сеть VPC

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-subnet-alb.id # Публичная подсеть для ALB
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {} # Запросить публичный IP-адрес
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id # Финальная ссылка на HTTP Router
      }
    }
  }
}

locals {
  bastion_name           = yandex_compute_instance.vm-bastion.name
  bastion_external_ip    = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
  bastion_internal_ip    = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
  bastion_zone           = yandex_compute_instance.vm-bastion.zone
  vm_1_name              = yandex_compute_instance.vm-server-1.name
  vm_1_external_ip       = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
  vm_1_internal_ip       = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
  vm_1_zone              = yandex_compute_instance.vm-server-1.zone
  vm_2_name              = yandex_compute_instance.vm-server-2.name
  vm_2_external_ip       = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
  vm_2_internal_ip       = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
  vm_2_zone              = yandex_compute_instance.vm-server-2.zone
  prometheus_name        = yandex_compute_instance.vm-prometheus.name
  prometheus_external_ip = yandex_compute_instance.vm-prometheus.network_interface.0.nat_ip_address
  prometheus_internal_ip = yandex_compute_instance.vm-prometheus.network_interface.0.ip_address
  prometheus_zone        = yandex_compute_instance.vm-prometheus.zone
}

output "ansible_inventory" {
  value = templatefile("${path.module}/ansible_inventory.tpl", {
    bastion_name           = yandex_compute_instance.vm-bastion.name
    bastion_external_ip    = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
    bastion_internal_ip    = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
    bastion_zone           = yandex_compute_instance.vm-bastion.zone
    vm_1_name              = yandex_compute_instance.vm-server-1.name
    vm_1_external_ip       = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
    vm_1_internal_ip       = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
    vm_1_zone              = yandex_compute_instance.vm-server-1.zone
    vm_2_name              = yandex_compute_instance.vm-server-2.name
    vm_2_external_ip       = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
    vm_2_internal_ip       = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
    vm_2_zone              = yandex_compute_instance.vm-server-2.zone
    prometheus_name        = yandex_compute_instance.vm-prometheus.name
    prometheus_external_ip = yandex_compute_instance.vm-prometheus.network_interface.0.nat_ip_address
    prometheus_internal_ip = yandex_compute_instance.vm-prometheus.network_interface.0.ip_address
    prometheus_zone        = yandex_compute_instance.vm-prometheus.zone
  })
  description = "Содержимое для Ansible inventory файла"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible_inventory.tpl", {
    bastion_name           = yandex_compute_instance.vm-bastion.name
    bastion_external_ip    = yandex_compute_instance.vm-bastion.network_interface.0.nat_ip_address
    bastion_internal_ip    = yandex_compute_instance.vm-bastion.network_interface.0.ip_address
    bastion_zone           = yandex_compute_instance.vm-bastion.zone
    vm_1_name              = yandex_compute_instance.vm-server-1.name
    vm_1_external_ip       = yandex_compute_instance.vm-server-1.network_interface.0.nat_ip_address
    vm_1_internal_ip       = yandex_compute_instance.vm-server-1.network_interface.0.ip_address
    vm_1_zone              = yandex_compute_instance.vm-server-1.zone
    vm_2_name              = yandex_compute_instance.vm-server-2.name
    vm_2_external_ip       = yandex_compute_instance.vm-server-2.network_interface.0.nat_ip_address
    vm_2_internal_ip       = yandex_compute_instance.vm-server-2.network_interface.0.ip_address
    vm_2_zone              = yandex_compute_instance.vm-server-2.zone
    prometheus_name        = yandex_compute_instance.vm-prometheus.name
    prometheus_external_ip = yandex_compute_instance.vm-prometheus.network_interface.0.nat_ip_address
    prometheus_internal_ip = yandex_compute_instance.vm-prometheus.network_interface.0.ip_address
    prometheus_zone        = yandex_compute_instance.vm-prometheus.zone
  })
  filename = "${path.module}/terraform_generated.ini"

  depends_on = [
    yandex_compute_instance.vm-bastion,
    yandex_compute_instance.vm-server-1,
    yandex_compute_instance.vm-server-2
  ]
}
