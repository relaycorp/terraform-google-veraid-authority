module "awala" {
  count = var.awala_endpoint_enabled ? 1 : 0

  source = "./modules/awala"

  docker_image_name = var.docker_image_name
  docker_image_tag  = var.docker_image_tag

  instance_name = var.instance_name

  service_account_email = google_service_account.main.email

  project_id           = var.project_id
  region               = var.region
  kms_keyring          = google_kms_key_ring.main.name
  kms_protection_level = var.kms_protection_level

  log_level = var.log_level

  mongodb_uri                = var.mongodb_uri
  mongodb_db                 = var.mongodb_db
  mongodb_user               = var.mongodb_user
  mongodb_password_secret_id = google_secret_manager_secret.mongodb_password.id

  queue_cpu_limit                        = var.queue_cpu_limit
  queue_max_instance_count               = var.queue_max_instance_count
  queue_max_instance_request_concurrency = var.queue_max_instance_request_concurrency
  queue_min_instance_count               = var.queue_min_instance_count

  queue_member_bundle_trigger_schedule_utc = var.queue_member_bundle_trigger_schedule_utc

  awala_backend_cpu_limit                        = var.awala_backend_cpu_limit
  awala_backend_max_instance_count               = var.awala_backend_max_instance_count
  awala_backend_max_instance_request_concurrency = var.awala_backend_max_instance_request_concurrency
  awala_backend_min_instance_count               = var.awala_backend_min_instance_count

  awala_endpoint_outgoing_messages_topic = var.awala_endpoint_outgoing_messages_topic
  awala_endpoint_incoming_messages_topic = var.awala_endpoint_incoming_messages_topic

  depends_on = [
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
  ]
}
