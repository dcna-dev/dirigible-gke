terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs" {}
}

data "terraform_remote_state" "gke" {
  backend = "gcs"
  config {
    bucket = "${var.bucket}"
    prefix = "${var.prefix}"
    project = "${var.project}"
  }
}

provider "kubernetes" {
  host = "${data.terraform_remote_state.gke.host}"
  username               = "${var.username}"
  password               = "${var.password}"
  client_certificate     = "${base64decode(data.terraform_remote_state.gke.client_certificate)}"
  client_key             = "${base64decode(data.terraform_remote_state.gke.client_key)}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.gke.cluster_ca_certificate)}"

  load_config_file = false
}

resource "kubernetes_config_map" "postgres-config" {
  metadata {
    name = "postgres-config"
  }
  data = {
    POSTGRES_DB = "${var.DB}"
    POSTGRES_USER = "${var.DB_USER}"
  }
}

resource "kubernetes_secret" "postgresql" {
  metadata {
    name = "postgres-pass"
  }

  data {
    password = "${var.DB_PASSWORD}"
  }
}

resource "kubernetes_persistent_volume_claim" "postgresql" {
  metadata {
    name = "postgresql"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "${var.postgres_storage}"
      }
    }
  }
}


resource "kubernetes_deployment" "postgresql" {
  metadata {
    name = "postgresql"
    labels {
      app = "postgresql"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels {
        app = "postgresql"
      }
    }
    template {
      metadata {
        labels {
          app = "postgresql"
        }
      }
      spec {
        container {
          image = "postgres:alpine"
          name  = "postgresql"
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "${kubernetes_secret.postgresql.metadata.0.name}"
                key = "password"
              }
            }
          }
          env_from {
            config_map_ref {
              name = "postgres-config"
            }
          }
          port {
            container_port = 5432
          }
          volume_mount {
            name = "postgres-storage"
            mount_path = "/var/lib/pgsql"
          }
        }
        volume {
          name = "postgres-storage"
          persistentVolumeClaim {
            claim_name = "${kubernetes_persistent_volume_claim.postgresql.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres_service" {
  metadata {
    name = "postgresql"
  }
  spec {
    selector {
      app = "${kubernetes_deployment.postgresql.metadata.0.labels.app}"
    }
    port {
      port = 5432
    }
  }
}

