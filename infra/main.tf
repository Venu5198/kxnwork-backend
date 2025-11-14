terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "artifact" {
  service = "artifactregistry.googleapis.com"
}

resource "google_compute_network" "vpc" {
  name = "kxnwork-vpc"
}

resource "google_compute_firewall" "app_firewall" {
  name    = "allow-app-port"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh_access" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "backend-repo"
  format        = "DOCKER"
}

resource "google_service_account" "vm_sa" {
  account_id   = "kxnwork-vm-sa"
  display_name = "VM service account for pulling images"
}

resource "google_project_iam_member" "vm_artifact_reader" {
  project = var.project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_compute_instance" "vm" {
  name         = "kxnwork-backend-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
    access_config {}
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")
}
