terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs" {}
}

provider "kubernetes" {
#  host = "${var.host}"
  username               = "${var.username}"
  password               = "${var.password}"
#  client_certificate     = "${base64decode(var.client_certificate)}"
#  client_key             = "${base64decode(var.client_key)}"
#  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
  host     = "${var.host}"
  client_certificate     = "${var.client_certificate}"
  client_key             = "${var.client_key}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"


  load_config_file = false
}

resource "kubernetes_config_map" "dirigible-config" {
  metadata {
    name = "dirigible-config"
  }
  data = {
    POSTGRES_DB = "${var.DB}"
    POSTGRES_PASSWORD = "${var.DB_PASSWORD}"
    POSTGRES_USER = "${var.DB_USER}"

    DIRIGIBLE_DATABASE_PROVIDER="custom"
    DIRIGIBLE_DATABASE_CUSTOM_DATASOURCES="POSTGRES"
    DIRIGIBLE_DATABASE_DATASOURCE_NAME_DEFAULT="POSTGRES"
    POSTGRES_DRIVER="org.postgresql.Driver"
    POSTGRES_URL="jdbc:postgresql://postgresql:5432/${var.DB}"
    DIRIGIBLE_SCHEDULER_DATABASE_DRIVER="org.postgresql.Driver"
    DIRIGIBLE_SCHEDULER_DATABASE_URL="jdbc:postgresql://postgresql:5432/${var.DB}"
    DIRIGIBLE_SCHEDULER_DATABASE_USER="${var.DB_USER}"
    DIRIGIBLE_SCHEDULER_DATABASE_PASSWORD="${var.DB_PASSWORD}"
    DIRIGIBLE_SCHEDULER_DATABASE_DELEGATE="org.quartz.impl.jdbcjobstore.PostgreSQLDelegate"
  }
}


resource "kubernetes_deployment" "app" {
  metadata {
    name = "dirigible"
    labels {
      app = "dirigible"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels {
        app = "dirigible"
      }
    }
    template {
      metadata {
        labels {
          app = "dirigible"
        }
      }
      spec {
        container {
          image = "gcr.io/dirigible-gke/dirigible2"
          name  = "dirigible"
          env_from {
            config_map_ref {
              name = "dirigible-config"
            }
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name = "dirigible"
  }
  spec {
    selector {
      app = "${kubernetes_deployment.app.metadata.0.labels.app}"
    }
    port {
      port = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

