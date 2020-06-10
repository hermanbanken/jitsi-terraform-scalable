provider "google" {
  project = var.gcp_project
  version = "~> 3.0"
}

resource "random_id" "rnd" {
  byte_length = 4
}

locals {
  shard_id = random_id.rnd
}

resource "google_dns_managed_zone" "default" {
  # Import this resource!
  lifecycle {
    prevent_destroy = true # imported, do not delete
  }
}

resource "google_dns_record_set" "meet" {
  name = "meet-${locals.shard_id}"
  type = "A"
  ttl  = 300
  managed_zone = google_dns_managed_zone.default.name
  rrdatas = [google_compute_instance_from_template.meet.network_interface[0].access_config[0].nat_ip]
}

locals {
  shared_script = templatefile("${path.module}/scripts/jitsi-shared.sh.tpl", {
    jitsi_hostname = var.jitsi_hostname
    jitsi_jvbsecret = "random" // todo
  })
  meet_script = templatefile("${path.module}/scripts/jitsi-meet.sh.tpl", {
    jitsi_hostname = var.jitsi_hostname
    jitsi_bucket_certificates = var.jitsi_bucket_certificates
    jitsi_xmpp_auth_password = "todo"
  })
  jvb_script = templatefile("${path.module}/scripts/jitsi-jvb.sh.tpl", {
    jitsi_hostname = var.jitsi_hostname
    jitsi_bucket_certificates = var.jitsi_bucket_certificates
    jitsi_xmpp_auth_password = "todo"
  })
}
