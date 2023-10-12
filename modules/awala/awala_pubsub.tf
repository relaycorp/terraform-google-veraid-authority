resource "google_service_account" "awala_backend_invoker" {
  project = var.project_id

  account_id   = "authority-${var.instance_name}-awala-invoker"
  display_name = "VeraId Authority, Cloud Run service invoker for Awala backend"
}

resource "google_cloud_run_service_iam_binding" "awala_backend_invoker" {
  project = var.project_id

  location = google_cloud_run_v2_service.awala_backend.location
  service  = google_cloud_run_v2_service.awala_backend.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.awala_backend_invoker.email}"]
}

resource "google_pubsub_subscription" "awala_incoming_messages" {
  project = var.project_id

  name  = "authority-${var.instance_name}-awala.incoming-messages"
  topic = var.awala_endpoint_incoming_messages_topic

  filter = "hasPrefix(attributes.datacontenttype, \"application/vnd.veraid-authority.\")"

  ack_deadline_seconds       = 10
  message_retention_duration = "259200s" # 3 days
  retain_acked_messages      = false
  expiration_policy {
    ttl = "" # Never expire
  }

  push_config {
    push_endpoint = google_cloud_run_v2_service.awala_backend.uri
    oidc_token {
      service_account_email = google_service_account.awala_backend_invoker.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "5s"
  }
}

resource "google_pubsub_topic_iam_member" "awala_outgoing_messages_publisher" {
  project = var.project_id

  topic  = var.awala_endpoint_outgoing_messages_topic
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_pubsub_topic_iam_member" "awala_queue_publisher" {
  project = var.project_id

  topic  = google_pubsub_topic.queue.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.service_account_email}"
}
