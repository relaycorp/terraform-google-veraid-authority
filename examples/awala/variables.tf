variable "google_project_id" {
  description = "Google project id"
}
variable "google_credentials_path" {
  description = "Path to Google credentials file"
}
variable "google_region" {
  description = "Google region"
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas public key"
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas private key"
  sensitive   = true
}
variable "mongodbatlas_project_id" {}

variable "api_auth_audience" {
  description = "The OAuth2 audience"
  type        = string
}
variable "superadmin_email_address" {
  description = "The email address of the superadmin"
}

# ===== Awala Internet Endpoint

variable "awala_internet_address" {
  description = "The Internet address for the Awala endpoint"
}
variable "awala_internet_pohttp_domain" {
  description = "The domain name for the PoHTTP server in the Awala Internet Endpoint"
}
