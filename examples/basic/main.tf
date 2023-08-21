module "authority" {
  source = "../.."

  backend_name = "test"

  project_id = var.google_project_id
  region     = var.google_region

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.mongodb_db_name
  mongodb_user     = mongodbatlas_database_user.main.username
  mongodb_password = random_password.mongodb_user_password.result

  api_auth_audience        = var.api_auth_audience
  superadmin_email_address = var.superadmin_email_address

  depends_on = [time_sleep.wait_for_services]
}
