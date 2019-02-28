variable "bucket" {
  description = "Bucket for gke module remote state"
}

variable "prefix" {
  description = "Prefix for gke module remote state"
}

variable "project" {
  description = "Project for gke module remote state"
}

variable "username" {
  description = "Kubernetes master username"
}

variable "password" {
  description = "Kubernetes master password"
}

variable "DB" {
  description = "Database name"
}

variable "DB_USER" {
  description = "Database user"
}

variable "DB_PASSWORD" {
  description = "Database password"
}

