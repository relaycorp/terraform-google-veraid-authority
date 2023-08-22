resource "google_cloud_run_v2_service" "api" {
  name     = "authority-api-${var.instance_name}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    timeout = "300s"

    service_account = google_service_account.main.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = var.api_max_instance_request_concurrency

    containers {
      name  = "api"
      image = "${var.docker_image_name}:${var.docker_image_tag}"

      args = ["api"]

      env {
        name  = "AUTHORITY_VERSION"
        value = var.docker_image_tag
      }

      env {
        name  = "MONGODB_URI"
        value = var.mongodb_uri
      }
      env {
        name  = "MONGODB_DB"
        value = var.mongodb_db
      }
      env {
        name  = "MONGODB_USER"
        value = var.mongodb_user
      }
      env {
        name = "MONGODB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.mongodb_password.id
            version = "latest"
          }
        }
      }

      // Auth
      env {
        name  = "OAUTH2_JWKS_URL"
        value = var.api_auth_jwks_url
      }
      env {
        name  = "OAUTH2_TOKEN_ISSUER"
        value = var.api_auth_token_issuer
      }
      env {
        name  = "OAUTH2_TOKEN_AUDIENCE"
        value = var.api_auth_audience
      }

      dynamic "env" {
        for_each = var.superadmin_email_address != null ? [1] : []

        content {
          name  = "AUTHORITY_SUPERADMIN"
          value = var.superadmin_email_address
        }
      }

      // @relaycorp/webcrypto-kms options
      env {
        name  = "KMS_ADAPTER"
        value = "GCP"
      }
      env {
        name  = "GCP_KMS_LOCATION"
        value = var.region
      }
      env {
        name  = "GCP_KMS_KEYRING"
        value = google_kms_key_ring.main.name
      }
      env {
        name  = "GCP_KMS_PROTECTION_LEVEL"
        value = var.kms_protection_level
      }

      env {
        name  = "LOG_LEVEL"
        value = var.log_level
      }
      env {
        name  = "LOG_TARGET"
        value = "gcp"
      }

      env {
        name  = "REQUEST_ID_HEADER"
        value = "X-Cloud-Trace-Context"
      }

      resources {
        startup_cpu_boost = true
        cpu_idle          = false

        limits = {
          cpu    = var.api_cpu_limit
          memory = "512Mi"
        }
      }

      startup_probe {
        initial_delay_seconds = 3
        failure_threshold     = 3
        period_seconds        = 10
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        failure_threshold     = 3
        period_seconds        = 20
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }
    }

    scaling {
      min_instance_count = var.api_min_instance_count
      max_instance_count = var.api_max_instance_count
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
  ]
}

resource "google_cloud_run_service_iam_member" "api_invoker" {
  location = google_cloud_run_v2_service.api.location
  project  = google_cloud_run_v2_service.api.project
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
