variable "project_id" {
  description = "Google GCP Project ID"
}

variable "region" {
  description = "Google GCP Region"
}

variable "zone" {
  description = "Google GCP Zone"
}

variable "cluster_name" {
  description = "GKE Cluster name"
}

variable "initial_node_count" {
  description = "How many GKE nodes to run"
}

variable "username" {
  description = "Master auth username"
}

variable "password" {
  description = "Master auth password"
}

