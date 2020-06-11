export JVB_NICKNAME=`hostname`

# Installation
# https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable#installation-of-videobridges
apt-get install -qq jitsi-videobridge2
# current version = 2.1-202-g5f9377b9-1
# code = https://github.com/jitsi/jitsi-videobridge/tree/5f9377b9b2c8201a02e047426e341874f43ca1ee

# Configuration; and relevant MUC documentation
# https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-scalable#configuration-of-the-videobridge
# https://github.com/jitsi/jitsi-videobridge/blob/0d6fb601878cbc735faa7261b9cc06195c842e41/doc/muc.md
echo "Configuring jitsi-videobridge2 with nickname $${JVB_NICKNAME}"

cat << EOF > /etc/jitsi/videobridge/config
${file_videobridge_config}
EOF

sed -i "s|JITSI_INTERNAL_HOSTNAME|${jitsi_internal_hostname}|g" /etc/jitsi/videobridge/config
sed -i "s|JITSI_HOSTNAME|${jitsi_hostname}|g" /etc/jitsi/videobridge/config
sed -i "s|JITSI_JVB_SECRET|${jitsi_jvbsecret}|g" /etc/jitsi/videobridge/config

cat << EOF > /etc/jitsi/videobridge/sip-communicator.properties
${file_sip_communicator}
EOF

sed -i "s|JITSI_INTERNAL_HOSTNAME|${jitsi_internal_hostname}|g" /etc/jitsi/videobridge/sip-communicator.properties
sed -i "s|JITSI_HOSTNAME|${jitsi_hostname}|g" /etc/jitsi/videobridge/sip-communicator.properties
sed -i "s|JITSI_JVB_SECRET|${jitsi_jvbsecret}|g" /etc/jitsi/videobridge/sip-communicator.properties
sed -i "s|JVB_NICKNAME|$${JVB_NICKNAME}|g" /etc/jitsi/videobridge/sip-communicator.properties

# Reload
/etc/init.d/jitsi-videobridge2 restart
