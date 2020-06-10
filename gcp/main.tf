provider "google" {
  project = var.gcp_project
  version = "~> 3.0"
}

locals {
  shared_script = templatefile("${path.module}/scripts/jitsi-shared.sh.tpl", {
    jitsi_hostname = var.jitsi_hostname
    jitsi_jvbsecret = "random" // todo
  })
  haproxy_script = templatefile("${path.module}/scripts/jitsi-haproxy.sh.tpl", {
    jitsi_hostname = var.jitsi_hostname
    jitsi_bucket_certificates = var.jitsi_bucket_certificates
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

