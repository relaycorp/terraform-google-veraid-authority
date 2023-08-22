resource "google_service_account" "main" {
  project = var.project_id

  account_id   = "authority-${var.instance_name}"
  display_name = "VeraId Authority (${var.instance_name})"
}
