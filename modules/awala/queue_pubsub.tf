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
  name  = "authority.${var.instance_name}.queue"
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
