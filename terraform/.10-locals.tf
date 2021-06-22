locals {
  region             = "europe-west3"
  org_id             = "721786746734"
  billing_account    = "01E355-966D21-9F6142"
  host_project_name  = "rart-temp"
  host_project_id    = "rart-temp"
  cluster_name       = var.cluster_name
  cluster_region     = "europe-west3"
  cluster_zones      = ["europe-west3-c"]
  cluster_network    = "default"
  cluster_subnetwork = "default"
  projects_api       = "container.googleapis.com"
  secondary_ip_ranges = {
    "pod-ip-range"     = "10.0.0.0/24"
    "service-ip-range" = "10.1.0.0/24"
  }
}
