echo "Starting to install Jitsi Video Bridge" >> /debug.txt
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
apt-get install jitsi-videobridge2

# Is this still needed?
# Source: https://github.com/jitsi/jitsi-meet/blob/4080/doc/manual-install.md
# No: "With the latest stable (April 2020) videobridge, it is no longer necessary to set public and private IP adresses in the sip-communicator.properties as the bridge will figure out the correct configuration by itself."
# Source: https://github.com/jitsi/jitsi-meet/blob/4080/doc/scalable-installation.md
# ~/.sip-communicator/sip-communicator.properties
# org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=<Local.IP.Address>
# org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=<Public.IP.Address>