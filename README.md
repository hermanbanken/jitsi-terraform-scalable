# Terraform configuration for a scalable Jitsi Meet setup

Currently supports Google Cloud Platform (GCP) only.

## How it works

- Creates an 3 kinds of Managed Instance Groups (mig):
  1. HAProxy: 1 or more HAProxies for failover with sticky routing to jitsi-meet
  2. jitsi-meet (prosody, jicofo, jitsi-meet, nginx): 1 or more jitsi meet servers for redundancy
  3. jitsi-video-bridge (JVB/SFU): more than 2 jvb for scalability
- Creates startup scripts for each of the instance groups above
- Creates required firewall configuration

## Example configuration

```bash
terraform init
terraform import -var-file=terraform.tfvars.json google_compute_network.default default
terraform import -var-file=terraform.tfvars.json google_dns_managed_zone.default [name of your preconfigured dns zone]
terraform apply -var-file terraform.tfvars.json
```

`terraform.tfvars.json` could look like this:

```json
{
  "gcp_project": "your-gcp-project-1234",
  "dnszone_name": "yourdnszone",
  "dnszone_dnsname": "yourdnszone.example.org.",
  "jitsi_hostname": "jitsi.example.org",
  "jitsi_bucket_certificates": "jitsi-bucket-preshared-certificates-1234",
  "jitsi_shard": {
    "id": 1,
    "size": 2,
    "region": "europe-west4",
    "zone": "europe-west4-b",
    "machineType": "n2-standard-4"
  }
}
```

## References / contribution

- https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable
- https://jitsi.github.io/handbook/docs/devops-guide/secure-domain
- https://github.com/mavenik/jitsi-terraform/blob/master/aws/main.tf
- Downtime = "reload screen", how it is on meet.jit.si. https://community.jitsi.org/t/update-a-jitsi-meet-shard-without-service-downtime/33860/2
- Terraform: https://www.terraform.io/docs/providers/google/
- https://github.com/jitsi/jitsi-meet/commit/f2df5906f6231cb586257d23055f545c24200350
- Load Balance based on `room=[roomid]` parameter: https://community.jitsi.org/t/jitsi-meet-jicofo-jvb-prosody-high-availability-and-load-balance/21450/4
