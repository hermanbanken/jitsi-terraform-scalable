resource "google_compute_instance_from_template" "meet" {
  name         = "jitsi-${locals.shard_id}-meet"
  source_instance_template = google_compute_instance_template.meet.id
  machine_type = var.jitsi_shard.machineType
  zone         = var.jitsi_shard.zone
}

module "mig-jvb" {
  # Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  region            = var.jitsi_shard.region
  name              = "jitsi-${locals.shard_id}-jvb"
	instance_template = google_compute_instance_template.jvb.output.selfLink
  minReplicas       = 2
  maxReplicas       = 20
}
