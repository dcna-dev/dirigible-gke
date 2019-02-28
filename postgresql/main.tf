terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs" {}
}

provider "kubernetes" {
  host = "${var.host}"
  username               = "${var.username}"
  password               = "${var.password}"
  client_certificate     = "${base64decode(var.client_certificate)}"
  client_key             = "${base64decode(var.client_key)}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"

  load_config_file = false
}

resource "kubernetes_config_map" "postgres-config" {
  metadata {
    name = "postgres-config"
  }
  data = {
    POSTGRES_DB = "${var.DB}"
    POSTGRES_PASSWORD = "${var.DB_PASSWORD}"
    POSTGRES_USER = "${var.DB_USER}"
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
          env_from {
            config_map_ref {
              name = "postgres-config"
            }
          }
          port {
            container_port = 5432
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
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
