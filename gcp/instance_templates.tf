resource "google_compute_instance_template" "meet" {
  name = "jitsi-template-meet"
  tags = ["allow-jitsi-meet"]
  labels = { "shard" = var.jitsi_shard.id }
  machine_type         = var.jitsi_shard.machineType
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }
  metadata = {
    "startup-script" = "${local.shared_script}\n ${local.meet_script}"
  }
  network_interface {
    network = "default"
    access_config {}
  }
	service_account { scopes = ["userinfo-email", "compute-ro", "storage-ro", "logging-write"] }
}

resource "google_compute_instance_template" "jvb" {
  name        = "jitsi-template-jvb"
  tags = ["allow-jitsi-jvb"]
  labels = { "shard" = var.jitsi_shard.id }
  machine_type         = var.jitsi_shard.machineType
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    "startup-script" = "${local.shared_script}\n ${local.jvb_script}"
  }
  service_account { scopes = ["userinfo-email", "compute-ro", "storage-ro", "logging-write"] }
}
