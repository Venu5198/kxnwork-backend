output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
output "artifact_repo" {
  value = google_artifact_registry_repository.repo.id
}

