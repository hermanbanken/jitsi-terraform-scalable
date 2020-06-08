# Terraform configuration for a scalable Jitsi Meet setup

Currently supports Google Cloud Platform (GCP) only.

## How it works

* Creates an 3 kinds of Managed Instance Groups (mig):
  1. HAProxy: 1 or more HAProxies for failover with sticky routing to jitsi-meet
  2. jitsi-meet (prosody, jicofo, jitsi-meet, nginx): 1 or more jitsi meet servers for redundancy
  3. jitsi-video-bridge (JVB/SFU): more than 2 jvb for scalability
* Creates startup scripts for each of the instance groups above
* Creates required firewall configuration

## Example configuration
`terraform.tfvars.json` could look like this:
```json
{
	"gcp_project": "your-gcp-project-1234",
	"jitsi_hostname": "jitsi.example.org",
	"jitsi_shards": [{
    "id": 1,
    "size": 2,
    "region": "europe-west4",
    "zone": "europe-west4-b",
    "machineType": "n2-standard-4"
  }, {
    "id": 2,
    "size": 2,
    "region": "europe-west4",
    "zone": "europe-west4-c",
    "machineType": "n2-standard-4"
  }]
}
```
