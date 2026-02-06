variable "yc_token" {
  description = "OAuth token или service account key" 
  type = string
  default = null
}
variable "yc_cloud_id" {
  type = string
}
variable "yc_folder_id" {
  type = string 
}
variable "yc_zone" {
  type = string
  default = "ru-central1-a"
}

variable "ssh_public_key" {
  type = string
  description = "Путь к публичному SSH ключу"
}

# Параметры ВМ
variable "monitoring_vm" { 
  type = map(object({
    cores         = number
    memory        = number
    disk_size     = number
    image_family  = string
  }))
  default = {
    "monitor" = {
      cores        = 2
      memory       = 4
      disk_size    = 20
      image_family = "ubuntu-2404-lts"
    }
  }
}

variable "client_vm" {
  type = map(object({
    cores         = number
    memory        = number
    disk_size     = number
    image_family  = string
  }))
  default = {
    "client" = {
      cores        = 2
      memory       = 2
      disk_size    = 10
      image_family = "ubuntu-2404-lts"
    }
  }
}
