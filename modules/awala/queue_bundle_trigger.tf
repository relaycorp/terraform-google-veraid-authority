resource "google_cloud_scheduler_job" "queue_member_bundle_trigger" {
  project = var.project_id
  region  = var.region

  name        = "authority-${var.instance_name}-queue-member-bundle-trigger"
  description = "Trigger generation of member id bundles"
  schedule    = var.queue_member_bundle_trigger_schedule_utc

  pubsub_target {
    topic_name = google_pubsub_topic.queue.id
    attributes = {
      type   = "net.veraid.authority.member-bundle-request-trigger"
      source = "https://github.com/relaycorp/terraform-google-veraid-authority"
    }
    data = base64encode("ignored")
  }
}
