# Сеть
resource "yandex_vpc_network" "network" {
  name = "monitoring-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "monitoring-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Security Group (Файрвол)
resource "yandex_vpc_security_group" "sg" {
  name        = "monitoring-sg"
  network_id  = yandex_vpc_network.network.id
  description = "Allow SSH and Monitoring ports"

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "TCP"
    description    = "Prometheus"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9090
  }

  # Egress rules for updates, etc.
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Monitoring VM
data "yandex_compute_image" "monitoring_image" {
  family = var.monitoring_vm["monitor"].image_family
}

resource "yandex_compute_instance" "monitoring" {
  name        = "monitoring-server"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.monitoring_vm["monitor"].cores
    memory = var.monitoring_vm["monitor"].memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.monitoring_image.id
      size     = var.monitoring_vm["monitor"].disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}

# Client VM
data "yandex_compute_image" "client_image" {
  family = var.client_vm["client"].image_family
}

resource "yandex_compute_instance" "client" {
  name        = "client-server"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = var.client_vm["client"].cores
    memory = var.client_vm["client"].memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.client_image.id
      size     = var.client_vm["client"].disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
    # Note: In prod restrict security groups strictly
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}