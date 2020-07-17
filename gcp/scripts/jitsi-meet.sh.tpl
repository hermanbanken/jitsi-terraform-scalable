echo "Starting to install Jitsi Meet (prosody, jicofo, meet)"

# Include shared preparations above this line.
apt-get -y install \
  nginx wget \
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
cd /tmp

# Enable CORS for BOSH in Prosody Lua config
sed -i "s|cross_domain_bosh = false|cross_domain_bosh = true|g" /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua
/etc/init.d/prosody restart
/etc/init.d/jicofo restart

# Enable TurnCredentials
# Use with Jitsi Meet Config option "useStunTurn: true"
# see https://meetrix.io/blog/webrtc/jitsi/setting-up-a-turn-server-for-jitsi-meet.html
curl https://raw.githubusercontent.com/otalk/mod_turncredentials/master/mod_turncredentials.lua > mod_turncredentials.lua
cp mod_turncredentials.lua /usr/lib/prosody/modules/
sed -i 's|"bosh";|"bosh";"turncredentials";|g' /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua

# prepend these settings:
cat <<\EOF >> turnsettings.lua.tmp
turncredentials_host = "${COTURN_REALM}";
turncredentials_secret = "${COTURN_AUTH_SECRET}";
turncredentials_port = 443;
turncredentials_ttl = 86400;
turncredentials = {
    { type = "stun", host = "${COTURN_REALM}" },
    { type = "turn", host = "${COTURN_REALM}", port = 443},
    { type = "turns", host = "${COTURN_REALM}", port = 443, transport = "tcp" }
}
EOF
cat turnsettings.lua.tmp /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua > /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua.tmp
mv /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua.tmp /etc/prosody/conf.avail/${jitsi_hostname}.cfg.lua
/etc/init.d/prosody restart

# LetsEncrypt
if [ ! -d "/etc/letsencrypt/live" ]; then
  # See script: https://github.com/jitsi/jitsi-meet/blob/8758c222c6f4ffa6f2403ff1a4b097d3437b52a5/resources/install-letsencrypt-cert.sh
  echo "${lets_encrypt_email}" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
  nginx -s reload
fi
