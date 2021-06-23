
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.1"
  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/8"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "172.16.0.0/12"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.0.0/16"
      },
    ]
  }
}

module "gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google"
  project_id               = var.project_id
  name                     = var.cluster_name
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