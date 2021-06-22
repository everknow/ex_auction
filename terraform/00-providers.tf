terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.72.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "rart-temp"
  region  = "europe-west3"
}
