module "mig-haproxy" {
  # Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  region            = var.jitsi_shard.region
  name              = "jitsi-shard-${var.jitsi_shard.id}-haproxy"
	instance_template = google_compute_instance_template.haproxy.output.selfLink
  minReplicas       = 1
  maxReplicas       = 2
}

module "mig-meet" {
  # Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  region            = var.jitsi_shard.region
  name              = "jitsi-shard-${var.jitsi_shard.id}-meet"
	instance_template = google_compute_instance_template.meet.output.selfLink
  minReplicas       = 1
  maxReplicas       = 2
}

module "mig-jvb" {
  # Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/terraform-google-modules/terraform-google-vm/modules/mig"
  region            = var.jitsi_shard.region
  name              = "jitsi-shard-${var.jitsi_shard.id}-jvb"
	instance_template = google_compute_instance_template.jvb.output.selfLink
  minReplicas       = 2
  maxReplicas       = 20
}
