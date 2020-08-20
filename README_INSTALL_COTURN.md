# Coturn setup using GCP SSL loadbalancers

To easily configure a Managed Instance Group of Coturn servers, I followed these steps:

- Create a temporary 'coturn' VM with the install script below
- Create Image from this temporary VM
- Create Managed Instance Group from the image
- Create a SSL Proxy Load Balancer (see https://cloud.google.com/load-balancing/docs/ssl/setting-up-ssl) that targets this group

## Install script
Take care to insert the correct realm and replace COTURN_AUTH_SECRET_INSERT_HERE.

```
apt-get -qq update
apt-get -qq install coturn curl
echo "TURNSERVER_ENABLED=1" >> /etc/default/coturn
setcap 'cap_net_bind_service=+ep' /usr/bin/turnserver

cat <<\EOF > /etc/turnserver.conf
realm=coturn.gcp.borrel.app
fingerprint
listening-ip=0.0.0.0
listening-port=80
min-port=10000
max-port=20000
syslog
verbose
# Time-Limited Credentials Mechanism
use-auth-secret
static-auth-secret=COTURN_AUTH_SECRET_INSERT_HERE
EOF

service coturn restart
# see logs with: journalctl -f
```
