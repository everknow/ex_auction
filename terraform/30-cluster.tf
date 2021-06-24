locals {
  full_cluster_name = "${var.env_prefix}-${var.cluster_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.1"
  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnet
      subnet_ip     = var.subnet_range
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnet) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.ip_range_pods
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.ip_range_services
      },
    ]
  }
}

module "gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google"
  project_id               = var.project_id
  name                     = local.full_cluster_name
  regional                 = false
  zones                    = var.zones
  region                   = var.region
  network                  = module.gcp-network.network_name
  subnetwork               = module.gcp-network.subnets_names[0]
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  create_service_account   = false
  remove_default_node_pool = true
  node_pools = [
    {
      auto_scaling       = false
      name               = "test-rart-node-pool"
      machine_type       = "n1-standard-1"
      node_locations     = "europe-west3-c"
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.default_service_account.email
      preemptible        = false
      initial_node_count = 2
    },
  ]
}