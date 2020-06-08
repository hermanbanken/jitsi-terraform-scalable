echo "Starting to install Jitsi Meet (prosody, jicofo, meet)" >> /debug.txt
export XMPP_AUTH_PASSWORD="${jitsi_xmpp_auth_password}"

echo "Preparing configuration"
apt-get install debconf-utils
cat << EOF | sudo debconf-set-selections
jitsi-videobridge   jitsi-videobridge/jvb-hostname  string  ${jitsi_hostname}
jitsi-meet  jitsi-meet/jvb-serve    boolean false
jitsi-meet-prosody  jitsi-videobridge/jvb-hostname  string  ${jitsi_hostname}
jitsi-meet-web-config   jitsi-meet/cert-choice  select  I want to use my own certificate
jitsi-meet-web-config   jitsi-meet/cert-path-crt    string  /etc/ssl/${jitsi_hostname}.crt
jitsi-meet-web-config   jitsi-meet/cert-path-key    string  /etc/ssl/${jitsi_hostname}.key
EOF

echo "Installing packages"
apt-get install nginx prosody jicofo jitsi-meet-web jitsi-meet-prosody jitsi-meet-web-config

# https://github.com/jitsi/jitsi-meet/blob/4080/doc/manual-install.md
cat << EOF > /etc/nginx/sites-available/${jitsi_hostname}.conf
server_names_hash_bucket_size 64;

server {
    listen 0.0.0.0:443 ssl http2;
    listen [::]:443 ssl http2;
    # tls configuration that is not covered in this guide
    # we recommend the use of https://certbot.eff.org/
    server_name ${jitsi_hostname};
    # set the root
    root /srv/jitsi-meet;
    index index.html;
    location ~ ^/([a-zA-Z0-9=\?]+)$ {
        rewrite ^/(.*)$ / break;
    }
    location / {
        ssi on;
    }
    # BOSH, Bidirectional-streams Over Synchronous HTTP
    # https://en.wikipedia.org/wiki/BOSH_(protocol)
    location /http-bind {
        proxy_pass      http://localhost:5280/http-bind;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $http_host;
    }
    # external_api.js must be accessible from the root of the
    # installation for the electron version of Jitsi Meet to work
    # https://github.com/jitsi/jitsi-meet-electron
    location /external_api.js {
        alias /srv/jitsi-meet/libs/external_api.min.js;
    }
}
EOF

cd /etc/nginx/sites-enabled
ln -s ../sites-available/${jitsi_hostname}.conf ${jitsi_hostname}.conf
