terraform {
  required_providers {
    google = "~> 3.72"
  }

  # Terraform required version
  required_version = "1.0.0"
}

provider "google" {
  project = local.host_project_id
  region  = local.cluster_region
}
