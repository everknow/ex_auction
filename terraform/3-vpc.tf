resource "google_compute_network" "main-vpc" {

  name                    = "main-vpc"
  project                 = "rart-temp"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1500

}


resource "google_compute_subnetwork" "private" {
  name                     = "private"
  project                  = "rart-temp"
  ip_cidr_range            = "10.2.0.0/29"
  region                   = local.cluster_region
  network                  = google_compute_network.main-vpc.self_link
  private_ip_google_access = true


  #  secondary_ip_ranges = {
  #     "pod-ip-range"     = "10.0.0.0/24"
  #     "service-ip-range" = "10.1.0.0/24"
  #   }


  dynamic "secondary_ip_range" {
    for_each = local.secondary_ip_ranges

    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }
}
