resource "google_compute_network" "default" {
  name = "default" # import!
  description = var.network_description
	lifecycle {
    prevent_destroy = true # imported, do not delete
  }
}

# See https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable for this picture:
#               +                                       +
#               |                                       |
#               |                                       |
#               v                                       v
#          80, 443 TCP                          443 TCP, 10000 UDP
#       +--------------+                     +---------------------+
#       |  nginx       |  5222, 5347 TCP     |                     |
#       |  jitsi-meet  |<-------------------+|  jitsi-videobridge  |
#       |  prosody     |         |           |                     |
#       |  jicofo      |         |           +---------------------+
#       +--------------+         |
#                                |           +---------------------+
#                                |           |                     |
#                                +----------+|  jitsi-videobridge  |
#                                |           |                     |
#                                |           +---------------------+
#                                |
#                                |           +---------------------+
#                                |           |                     |
#                                +----------+|  jitsi-videobridge  |
#                                            |                     |
#                                            +---------------------+

resource "google_compute_firewall" "jitsi-frontend" {
  name    = "jitsi-frontend-${local.shard_id}"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["jitsi-meet", "jitsi-haproxy"]
}

resource "google_compute_firewall" "jitsi-internal" {
  name    = "jitsi-internal-${local.shard_id}"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["5222", "5347"] # Prosody, Jicofo
  }

  source_tags = ["jitsi-jvb"]
  target_tags = ["jitsi-meet"]
}

resource "google_compute_firewall" "jitsi-jvb" {
  name    = "jitsi-jvb-${local.shard_id}"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "4443"] # 4443 might not be needed anymore (separate jitsi-meet nginx)
  }

  allow {
    protocol = "udp"
    ports    = ["10000"]
  }

  target_tags = ["jitsi-jvb"]
}
