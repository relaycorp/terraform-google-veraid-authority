resource "google_cloud_run_v2_service" "queue" {
  name     = "authority-queue-${var.instance_name}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    timeout = "300s"

    service_account = var.service_account_email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = var.queue_max_instance_request_concurrency

    containers {
      name  = "queue"
      image = "${var.docker_image_name}:${var.docker_image_tag}"

      args = ["queue"]

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
            secret  = var.mongodb_password_secret_id
            version = "latest"
          }
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
        value = var.kms_keyring
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
        name  = "CE_TRANSPORT"
        value = "google-pubsub"
      }
      env {
        name  = "CE_CHANNEL_BACKGROUND_QUEUE"
        value = google_pubsub_topic.queue.id
      }
      env {
        name = "CE_CHANNEL_AWALA_OUTGOING_MESSAGES"
        // TODO: DEFINE
        value = var.awala_endpoint_outgoing_messages_topic
      }

      env {
        name  = "REQUEST_ID_HEADER"
        value = "X-Cloud-Trace-Context"
      }

      resources {
        startup_cpu_boost = true
        cpu_idle          = false

        limits = {
          cpu    = var.queue_cpu_limit
          memory = "512Mi"
        }
      }

      startup_probe {
        failure_threshold = 3
        period_seconds    = 10
        timeout_seconds   = 3
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
      min_instance_count = var.queue_min_instance_count
      max_instance_count = var.queue_max_instance_count
    }
  }
}
