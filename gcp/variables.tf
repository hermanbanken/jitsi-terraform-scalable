variable "gcp_project" {
  description = "GCP project"
  type        = string
}

variable "jitsi_hostname" {
  description = "Where it is hosted, example: jitsi.example.org"
  type = string
}

variable "jitsi_bucket_certificates" {
  description = "Name of GCS bucket containing the TLS certificates for Jitsi; files must be $jitsi_hostname.crt & $jitsi_hostname.key"
  type = string
}

variable "jitsi_shards" {
  description = "Amount of Jitsi Meet shards (prosody, jicofo, meet)"
  type        = list(object({
    id=number,
    size=number,
    region=string,
    zone=string,
    machineType=string
  }))
	default     = [{
    id = 1,
    size = 2,
    region = "europe-west1",
    zone = "europe-west1-b",
    machineType = "f1-micro"
  },{
    id = 2,
    size = 2,
    region = "europe-west1",
    zone = "europe-west1-c",
    machineType = "f1-micro"
  }]
}
