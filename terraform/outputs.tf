output "monitoring_public_ip" {
  value = yandex_compute_instance.monitoring.network_interface.0.nat_ip_address
  description = "Public IP of Monitoring Server"
}

output "client_public_ip" {
  value = yandex_compute_instance.client.network_interface.0.nat_ip_address
  description = "Public IP of Client Server"
}