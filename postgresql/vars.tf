variable "bucket" {
  description = "Bucket for gke module remote state"
}

variable "prefix" {
  description = "Prefix for gke module remote state"
}

variable "project" {
  description = "Project for gke module remote state"
}

variable "DB" {
  description = "Database name"
}

variable "DB_PASSWORD" {
  description = "Database user password"
}

variable "DB_USER" {
  description = "Database user"
}

variable "username" {
  description = "Kubernetes master username"
}

variable "password" {
  description = "Kubernetes master password"
}

variable "client_certificate" {
  description = "Kubernetes client certificate"
}

variable "client_key" {
  description = "Kubernetes client key"
}

variable "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
}

variable "host" {
  description = "Kubernetes host"
}


