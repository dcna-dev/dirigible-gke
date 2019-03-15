terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs"{}
}

provider "google" {
#  credentials = "${file("account.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.initial_node_count}"

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }
}

