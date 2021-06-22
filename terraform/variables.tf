variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "rart-temp"
}

variable "cluster_name" {
  description = "A suffix to append to the default cluster name"
  default     = "test-rart-cluster"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west3"
}

variable "zones" {
  description = "The zones to host the cluster in"
  default     = ["europe-west3-c"]
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-scv"
}

variable "zone" {
  description = "The zone to host the cluster in"
  default     = "europe-west3"
}

variable "network" {
  description = "The VPC network to host the cluster in"
  default     = "rart-network"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  default     = "rart-subnetwork"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
  default     = "10.0.0.0/24"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
  default     = "10.1.0.0/24"
}

variable "compute_engine_service_account" {
  description = "Service account to associate to the nodes in the cluster"
  default     = "rart-temp"
}

variable "skip_provisioners" {
  type        = bool
  description = "Flag to skip local-exec provisioners"
  default     = false
}

variable "enable_binary_authorization" {
  description = "Enable BinAuthZ Admission controller"
  default     = false
}