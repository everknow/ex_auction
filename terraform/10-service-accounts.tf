resource "google_service_account" "default_service_account" {
  account_id   = "rart-temp"
  display_name = "Terraform Service Account"
  description  = "Service account for Terraform orchestration"
}