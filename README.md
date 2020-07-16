# Terraform configuration for a scalable Jitsi Meet setup

Currently supports Google Cloud Platform (GCP) only.

Warning: `terraform apply` will delete old resources also, if you rename the shard for example.

## How it works

- Creates an 3 kinds of instances:

  1. jitsi-meet (prosody, jicofo, jitsi-meet, nginx): 1 jitsi-meet server
  2. jitsi-video-bridge (JVB/SFU): **more than 2 jvb** for scalability joined in a Managed Instance Group with autoscaling
  3. coturn

- Creates startup scripts for each of the instances above
- Creates required firewall configuration

## Manual steps
- `brew install terraform`
- Create terraform.tfvars.json
- [Verify <yoursubdomain.example.org> name with Google](https://www.google.com/webmasters/verification/verification?domain=yoursubdomain.example.org)

## Example configuration

```bash
terraform workspace list
terraform workspace new [MYNAME]
terraform workspace select [MYNAME]

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
  "lets_encrypt_email": "you@example.org",
  "jitsi_shard": {
    "id": 1,
    "size": 2,
    "random": "random",
    "region": "europe-west4",
    "zone": "europe-west4-b",
    "sfuMachineType": "n2-standard-4",
    "xmppMachineType": "n2-standard-2",
  }
}
```

## Debugging
```
# jitsi-meet
journalctl -f
tail -f /var/log/prosody/prosody.* /var/log/jitsi/jicofo.log
journalctl --since "1 hour ago" -f
# errors only:
journalctl --since "1 hour ago" -f -p "emerg".."crit"

# JVB
tail -f /var/log/jitsi/jvb.log
journalctl --since "1 hour ago" -f
```

## TODO
- [x] Implement scalable setup from https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable
- [ ] Add option for HAProxy for scalable/highly-available jitsi-meet and XMPP server
- [ ] Add option for secure domain: https://jitsi.github.io/handbook/docs/devops-guide/secure-domain

## References / contribution

- https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable
- https://jitsi.github.io/handbook/docs/devops-guide/secure-domain
- https://github.com/mavenik/jitsi-terraform/blob/master/aws/main.tf
- Downtime = "reload screen", how it is on meet.jit.si. https://community.jitsi.org/t/update-a-jitsi-meet-shard-without-service-downtime/33860/2
- Terraform: https://www.terraform.io/docs/providers/google/
- "doc/example-config-files/scalable" files in https://github.com/jitsi/jitsi-meet/commit/f2df5906f6231cb586257d23055f545c24200350
- Load Balance based on `room=[roomid]` parameter: https://community.jitsi.org/t/jitsi-meet-jicofo-jvb-prosody-high-availability-and-load-balance/21450/4
