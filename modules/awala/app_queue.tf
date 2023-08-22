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

# ===== PubSub

resource "google_pubsub_topic" "queue" {
  project = var.project_id

  name = "authority.${var.instance_name}.queue"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_service_account" "queue_invoker" {
  account_id   = "authority-${var.instance_name}-pubsub"
  display_name = "VeraId Authority (${var.instance_name}), background queue invoker"
}

resource "google_cloud_run_service_iam_binding" "queue_invoker" {
  location = google_cloud_run_v2_service.queue.location
  service  = google_cloud_run_v2_service.queue.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.queue_invoker.email}"]
}

resource "google_pubsub_subscription" "queue" {
  name  = "authority.${var.instance_name}.outgoing-messages"
  topic = google_pubsub_topic.queue.name

  ack_deadline_seconds       = 10
  message_retention_duration = "259200s" # 3 days
  retain_acked_messages      = false
  expiration_policy {
    ttl = "" # Never expire
  }

  push_config {
    push_endpoint = google_cloud_run_v2_service.queue.uri
    oidc_token {
      service_account_email = google_service_account.queue_invoker.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "5s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.queue_dead_letter.id
    max_delivery_attempts = 10
  }
}

resource "google_pubsub_topic" "queue_dead_letter" {
  project = var.project_id

  name = "authority.${var.instance_name}.queue.dead-letter"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_subscription_iam_binding" "queue_dead_letter" {
  project = var.project_id

  subscription = google_pubsub_subscription.queue.name
  role         = "roles/pubsub.subscriber"
  members      = ["serviceAccount:${google_project_service_identity.pubsub.email}", ]
}

resource "google_pubsub_topic_iam_binding" "queue_dead_letter" {
  project = var.project_id

  topic   = google_pubsub_topic.queue_dead_letter.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_project_service_identity.pubsub.email}", ]
}
