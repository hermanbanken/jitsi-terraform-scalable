resource "google_compute_instance_from_template" "meet" {
  name         = "jitsi-${local.shard_id}-meet-${uuid()}"
  source_instance_template = google_compute_instance_template.meet.id
  machine_type = var.jitsi_shard.machineType
  zone         = var.jitsi_shard.zone

  lifecycle { ignore_changes = [name] }
  network_interface {
    network = "default"
    access_config {
      public_ptr_domain_name = "${local.meet_hostname}."
      network_tier = "PREMIUM"
    }
  }
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
  cooldown_period = 120 /* seconds before metrics should be stable (read: after installation) */
  # health_check = google_compute_health_check.tcp_https_health_check.self_link

  # Either target_size or autoscaler:
  # target_size = 2
  autoscaling_cpu = [{
    target = 0.5
  }]
  autoscaling_enabled = true
}

resource "google_compute_health_check" "tcp_https_health_check" {
  name = "tcp-health-check"
  timeout_sec        = 2
  check_interval_sec = 10
  healthy_threshold   = 3
  unhealthy_threshold = 5
  tcp_health_check {
    port = "443"
  }
}