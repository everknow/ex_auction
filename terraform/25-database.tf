resource "google_sql_database_instance" "test-db" {
  count            = var.env_prefix == "test" ? 0 : 1
  name             = "test-instance-sql"
  database_version = "POSTGRES_13"
  region           = "europe-west3"

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {


      dynamic "authorized_networks" {
        for_each = [{ name = "whole", value = "0.0.0.0/0" }]
        iterator = apps

        content {
          name  = apps.value.name
          value = apps.value.value
        }
      }

      require_ssl = true

    }
  }
}

data "google_sql_ca_certs" "ca_certs" {
  instance = "test-instance-sql"
}

locals {
  furthest_expiration_time = reverse(sort([for k, v in data.google_sql_ca_certs.ca_certs.certs : v.expiration_time]))[0]
  latest_ca_cert           = [for v in data.google_sql_ca_certs.ca_certs.certs : v.cert if v.expiration_time == local.furthest_expiration_time]
}

output "db_latest_ca_cert" {
  description = "Latest CA cert used by the primary database server"
  value       = local.latest_ca_cert
  sensitive   = true
}