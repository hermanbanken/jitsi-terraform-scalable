resource "google_compute_instance_from_template" "meet" {
  name         = "jitsi-${local.shard_id}-meet"
  source_instance_template = google_compute_instance_template.meet.id
  machine_type = var.jitsi_shard.machineType
  zone         = var.jitsi_shard.zone
}

module "mig-jvb" {
  # Docs: https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/mig
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  project_id        = var.gcp_project
  region            = var.jitsi_shard.region
  hostname          = "jitsi-${local.shard_id}-jvb"
	instance_template = google_compute_instance_template.jvb.self_link
  min_replicas       = 2
  max_replicas       = 20
}
