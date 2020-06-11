export JVB_NICKNAME=$(hostname)

# Configuration; and relevant MUC documentation
# https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable#configuration-of-the-videobridge
# https://github.com/jitsi/jitsi-videobridge/blob/0d6fb601878cbc735faa7261b9cc06195c842e41/doc/muc.md
echo "Configuring jitsi-videobridge2 with nickanme \$JVB_NICKNAME"

cat << EOF > /etc/jitsi/videobridge/config
# Jitsi Videobridge settings

# sets the XMPP domain (default: none)
JVB_HOSTNAME=${jitsi_hostname}

# sets the hostname of the XMPP server (default: domain if set, localhost otherwise)
JVB_HOST=

# sets the port of the XMPP server (default: 5275)
JVB_PORT=5347

# sets the shared secret used to authenticate to the XMPP server
JVB_SECRET=${jitsi_jvbsecret}

# extra options to pass to the JVB daemon
JVB_OPTS="--apis=rest,"

# adds java system props that are passed to jvb (default are for home and logging config file)
JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=videobridge -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/videobridge/logging.properties"
EOF

cat << EOF > /etc/jitsi/jicofo/sip-communicator.properties
org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true
org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443
org.jitsi.jicofo.ALWAYS_TRUST_MODE_ENABLED=true
org.jitsi.videobridge.ENABLE_REST_SHUTDOWN=true

# Enable broadcasting stats/presence in a MUC
org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=muc,colibri,rest
org.jitsi.videobridge.STATISTICS_INTERVAL=5000

org.jitsi.videobridge.xmpp.user.shard-1.HOSTNAME=${jitsi_hostname}
org.jitsi.videobridge.xmpp.user.shard-1.DOMAIN=auth.${jitsi_hostname}
org.jitsi.videobridge.xmpp.user.shard-1.USERNAME=jvb
org.jitsi.videobridge.xmpp.user.shard-1.PASSWORD=${jitsi_jvbsecret}
org.jitsi.videobridge.xmpp.user.shard-1.MUC_JIDS=JvbBrewery@internal.auth.${jitsi_hostname}
org.jitsi.videobridge.xmpp.user.shard-1.MUC_NICKNAME=\$JVB_NICKNAME
org.jitsi.videobridge.xmpp.user.shard-1.DISABLE_CERTIFICATE_VERIFICATION=true
EOF

# IP addresses
# No: "With the latest stable (April 2020) videobridge, it is no longer necessary to set public and private IP adresses in the sip-communicator.properties as the bridge will figure out the correct configuration by itself."
# Source: https://github.com/jitsi/jitsi-meet/blob/4080/doc/scalable-installation.md
# ~/.sip-communicator/sip-communicator.properties
# org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=<Local.IP.Address>
# org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=<Public.IP.Address>

# Installation
# https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable#installation-of-videobridges
apt-get install -qq jitsi-videobridge2
