terraform {
  required_providers {
    google = "~> 3.72"
  }

  # Terraform required version
  required_version = "1.0.0"
}

provider "google" {
  project = var.host_project_id
  region  = var.cluster_region
}
