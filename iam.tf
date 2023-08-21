resource "google_service_account" "main" {
  project = var.project_id

  account_id   = "authority-${var.backend_name}"
  display_name = "VeraId Authority (${var.backend_name})"
}
