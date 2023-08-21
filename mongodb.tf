resource "google_secret_manager_secret" "mongodb_password" {
  project = var.project_id

  secret_id = "authority-${var.backend_name}_mongodb-password"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "mongodb_password" {
  secret      = google_secret_manager_secret.mongodb_password.id
  secret_data = var.mongodb_password
}

resource "google_secret_manager_secret_iam_binding" "mongodb_password_reader" {
  secret_id = google_secret_manager_secret.mongodb_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = ["serviceAccount:${google_service_account.main.email}"]
}
