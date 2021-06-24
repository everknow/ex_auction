variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "rart-temp"
}

variable "env_prefix" {
  description = "The prefix to use when creating the cluster"
}

# `env_prefix` must be defined as env var TF_VAR_env_prefix
variable "cluster_name" {
  description = "A suffix to append to the default cluster name"
  default     = "rart-cluster"
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
  description = "The range name for pods"
  default     = "ip-range-pods"
}

variable "ip_range_pods" {
  description = "The ip range to use for pods"
  default     = "172.16.0.0/12"
}


variable "ip_range_services_name" {
  description = "The services range name to user for services"
  default     = "ip-range-services"
}

variable "ip_range_services" {
  description = "The services range to use for services"
  default     = "192.168.0.0/16"
}

variable "zone" {
  description = "The zone to host the cluster in"
  default     = "europe-west3"
}

variable "network" {
  description = "The VPC network to host the cluster in"
  default     = "rart-network"
}

variable "subnet" {
  description = "The subnet to host the cluster in"
  default     = "rart-subnet"
}

variable "subnet_range" {
  description = "The subnet range"
  default     = "10.0.0.0/8"
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