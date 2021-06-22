resource "google_compute_global_address" "production-ip" {
  project      = "rart-temp" # Replace this with your service project ID in quotes
  name         = "production-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_global_address" "test-ip" {
  project      = "rart-temp" # Replace this with your service project ID in quotes
  name         = "test-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}