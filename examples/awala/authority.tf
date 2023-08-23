locals {
  authority_db_name = "veraid-authority"
}

module "authority" {
  source = "../.."

  instance_name = "test"

  project_id = var.google_project_id
  region     = var.google_region

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.authority_db_name
  mongodb_user     = mongodbatlas_database_user.authority.username
  mongodb_password = random_password.mongodb_authority_user_password.result

  api_auth_audience = var.api_auth_audience
  superadmin_sub    = var.superadmin_sub

  awala_endpoint_enabled                 = true
  awala_endpoint_outgoing_messages_topic = module.endpoint.pubsub_topics.outgoing_messages
  awala_endpoint_incoming_messages_topic = module.endpoint.pubsub_topics.incoming_messages

  depends_on = [time_sleep.wait_for_services]
}

resource "mongodbatlas_database_user" "authority" {
  project_id = var.mongodbatlas_project_id

  username           = "veraid-authority"
  password           = random_password.mongodb_authority_user_password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = local.authority_db_name
  }
}

resource "random_password" "mongodb_authority_user_password" {
  length = 32
}
