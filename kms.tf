resource "google_kms_key_ring" "main" {
  project = var.project_id

  # Key rings can be deleted from the Terraform state but not GCP, so let's add a suffix in case
  # we need to recreate it.
  name = "authority-${var.backend_name}-${random_id.unique_suffix.hex}"

  location = var.region
}

resource "google_project_iam_member" "kms_admin" {
  project = var.project_id

  role   = "roles/cloudkms.admin"
  member = "serviceAccount:${google_service_account.main.email}"

  condition {
    title      = "Limit app access to KMS key ring"
    expression = "resource.name.startsWith(\"${google_kms_key_ring.main.id}\")"
  }
}

resource "google_project_iam_member" "kms_operator" {
  project = var.project_id

  role   = "roles/cloudkms.cryptoOperator"
  member = "serviceAccount:${google_service_account.main.email}"

  condition {
    title      = "Limit app access to KMS key ring"
    expression = "resource.name.startsWith(\"${google_kms_key_ring.main.id}\")"
  }
}
