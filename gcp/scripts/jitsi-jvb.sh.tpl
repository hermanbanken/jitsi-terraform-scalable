# echo "Starting to install Jitsi Video Bridge" >> /debug.txt
# export XMPP_AUTH_PASSWORD="${jitsi_xmpp_auth_password}"

apt-get install jitsi-videobridge2

# TODO
# set JVB nickname to something GCP Compute hostname

# Is this still needed?
# Source: https://github.com/jitsi/jitsi-meet/blob/4080/doc/manual-install.md
# No: "With the latest stable (April 2020) videobridge, it is no longer necessary to set public and private IP adresses in the sip-communicator.properties as the bridge will figure out the correct configuration by itself."
# Source: https://github.com/jitsi/jitsi-meet/blob/4080/doc/scalable-installation.md
# ~/.sip-communicator/sip-communicator.properties
# org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=<Local.IP.Address>
# org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=<Public.IP.Address>
