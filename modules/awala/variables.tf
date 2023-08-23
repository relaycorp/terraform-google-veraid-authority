variable "docker_image_name" {}
variable "docker_image_tag" {}

variable "instance_name" {}

variable "log_level" {}

# ===== GCP

variable "project_id" {}
variable "region" {}
variable "service_account_email" {}
variable "kms_keyring" {}
variable "kms_protection_level" {}

# ===== MongoDB

variable "mongodb_uri" {}
variable "mongodb_db" {}
variable "mongodb_user" {}
variable "mongodb_password_secret_id" {}

# ====== Background queue

variable "queue_max_instance_request_concurrency" {
  type = number
}
variable "queue_min_instance_count" {
  type = number
}
variable "queue_max_instance_count" {
  type = number
}
variable "queue_cpu_limit" {
  type = number
}

variable "queue_member_bundle_trigger_schedule_utc" {
  type = string
}

# ===== Awala Internet Endpoint

variable "awala_endpoint_outgoing_messages_topic" {
  type = string
}
