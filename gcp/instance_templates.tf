resource "google_compute_instance_template" "meet" {
  name = "jitsi-meet-${uuid()}"
  tags = ["jitsi-meet"]
  labels = { "shard" = var.jitsi_shard.id }
  machine_type         = var.jitsi_shard.xmppMachineType
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }
  metadata = {
    "startup-script" = "${local.shared_script}\n ${local.meet_script}"
  }
  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }
  service_account { scopes = ["userinfo-email", "compute-ro", "storage-ro", "logging-write"] }
  lifecycle { ignore_changes = [name] }
}

resource "google_compute_instance_template" "jvb" {
  name        = "jitsi-jvb-${uuid()}"
  tags = ["jitsi-jvb"]
  labels = { "shard" = var.jitsi_shard.id }
  machine_type         = var.jitsi_shard.sfuMachineType
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-10"
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
  lifecycle { ignore_changes = [name] }
}
