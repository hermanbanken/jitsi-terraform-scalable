provider "gcp" {
  project = var.gcp_project
}

data "template_file" "jitsi-haproxy-startup-script" {
  template = "${file("${format("%s/scripts/jitsi-haproxy.sh.tpl", path.module)}")}"
  vars {
		cert_path = "/etc/ssl/TODO"
  }
}

data "template_file" "jitsi-meet-startup-script" {
  template = "${file("${format("%s/scripts/jitsi-meet.sh.tpl", path.module)}")}"
  vars {
		jitsi_hostname = var.jitsi_hostname
    XMPP_AUTH_PASSWORD = ""
    XMPP_JVB_COMPONENTS = 10
  }
}

data "template_file" "jitsi-jvb-startup-script" {
  template = "${file("${format("%s/scripts/jitsi-jvb.sh.tpl", path.module)}")}"
  vars {
		jitsi_hostname = var.jitsi_hostname
    XMPP_AUTH_PASSWORD = ""
  }
}

module "mig-haproxy" {
	# Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/GoogleCloudPlatform/terraform-google-managed-instance-group"
  region            = var.jitsi_shards[0].region
  zone              = var.jitsi_shards[0].zone
  name              = "jitsi-shard-${var.jitsi_shards[0].index}-meet"
	machine_type      = var.jitsi_shards[0].machineType
  size              = 2
	compute_image     = "debian-cloud/debian-8"
  service_port      = 443
  service_port_name = "https"
  target_tags       = ["allow-jitsi-haproxy"]
  startup_script    = "${data.template_file.jitsi-haproxy-startup-script.rendered}"
}

module "mig-meet" {
	count             = length(var.jitsi_shards)
	# Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "github.com/GoogleCloudPlatform/terraform-google-managed-instance-group"
  region            = var.jitsi_shards[count.index].region
  zone              = var.jitsi_shards[count.index].zone
  name              = "jitsi-shard-${var.jitsi_shards[count.index].index}-meet"
	machine_type      = var.jitsi_shards[count.index].machineType
  size              = 1
	compute_image     = "debian-cloud/debian-8"
  service_port      = 443
  service_port_name = "https"
  target_tags       = ["allow-jitsi-meet"]
  startup_script    = "${data.template_file.jitsi-meet-startup-script.rendered}"
}

module "mig-jvb" {
	count             = length(var.jitsi_shards)
	# Docs: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.0
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.0.0"
  region            = var.jitsi_shards[count.index].region
  zone              = var.jitsi_shards[count.index].zone
  name              = "jitsi-shard-${var.jitsi_shards[count.index].index}-jvbs"
	machine_type      = var.jitsi_shards[count.index].machineType
  size              = var.jitsi_shards[count.index].size
	compute_image     = "debian-cloud/debian-8"
  service_port      = 443
  service_port_name = "https"
  target_tags       = ["allow-jitsi-jvb"]
  startup_script    = "${data.template_file.jitsi-jvb-startup-script.rendered}"
}
