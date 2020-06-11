echo "Starting to install Jitsi Meet (prosody, jicofo, meet)"

# Include shared preparations above this line.
apt-get -y install \
  nginx \
  prosody jicofo jitsi-meet-web jitsi-meet-prosody jitsi-meet-web-config \
  google-cloud-sdk

# NGINX
# https://github.com/jitsi/jitsi-meet/blob/4080/doc/manual-install.md
# https://github.com/jitsi/jitsi-meet/blob/8758c222c6f4ffa6f2403ff1a4b097d3437b52a5/doc/example-config-files/multidomain/jitsi.example.com.multidomain.example
rm /etc/nginx/sites-enabled/default
cat <<\EOF > /etc/nginx/sites-available/${jitsi_hostname}.conf
${file_nginx_site_conf}
EOF
sed -i "s|JITSI_HOSTNAME|${jitsi_hostname}|g" /etc/nginx/sites-available/${jitsi_hostname}.conf
cd /etc/nginx/sites-enabled
ln -s ../sites-available/${jitsi_hostname}.conf ${jitsi_hostname}.conf
nginx -s reload

# Enable CORS for BOSH in Prosody Lua config
sed -i "s|cross_domain_bosh = false|cross_domain_bosh = true|g" /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua
/etc/init.d/prosody restart
/etc/init.d/jicofo restart

# LetsEncrypt
if [ ! -d "/etc/letsencrypt/live" ]; then
  # See script: https://github.com/jitsi/jitsi-meet/blob/8758c222c6f4ffa6f2403ff1a4b097d3437b52a5/resources/install-letsencrypt-cert.sh
  echo "${lets_encrypt_email}" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
  nginx -s reload
fi
