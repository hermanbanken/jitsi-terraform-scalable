###
### https://meetrix.io/blog/webrtc/coturn/installation.html
###
apt-get -qq update
apt-get -qq install coturn curl
echo "TURNSERVER_ENABLED=1" >> /etc/default/coturn

cat <<\EOF > /etc/turnserver.conf
realm=COTURN_REALM
fingerprint
listening-ip=0.0.0.0
external-ip=EXTERNAL_IP
listening-port=3478
min-port=10000
max-port=20000
log-file=/var/log/turnserver.log
verbose
# Time-Limited Credentials Mechanism
static-auth-secret=COTURN_AUTH_SECRET
EOF

sed -i "s|COTURN_REALM|${COTURN_REALM}|g" /etc/turnserver.conf
sed -i "s|COTURN_AUTH_SECRET|${COTURN_AUTH_SECRET}|g" /etc/turnserver.conf
EXTERNAL_IP=`curl ifconfig.co/ip`
echo "Using EXTERNAL_IP $EXTERNAL_IP"
sed -i "s|EXTERNAL_IP|$$EXTERNAL_IP|g" /etc/turnserver.conf

service coturn restart

###
### LetsEncrypt
###

apt-get -y install software-properties-common &&\
add-apt-repository -y universe &&\
add-apt-repository -y ppa:certbot/certbot &&\
apt-get -y update &&\

apt-get -y install certbot
certbot certonly --standalone --preferred-challenges http -d ${COTURN_REALM}

cat <<\EOF >> /etc/turnserver.conf
server-name=COTURN_REALM
cert=/etc/letsencrypt/live/COTURN_REALM/cert.pem
pkey=/etc/letsencrypt/live/COTURN_REALM/privkey.pem
EOF
sed -i "s|COTURN_REALM|${COTURN_REALM}|g" /etc/turnserver.conf
service coturn restart
