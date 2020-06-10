echo "Starting to install HAProxy" >> /debug.txt

mkdir /etc/ssl/jitsi-meet
gsutil cp gs://${jitsi_bucket_certificates}/${jitsi_hostname}.crt /etc/ssl/jitsi-meet/cert.crt
gsutil cp gs://${jitsi_bucket_certificates}/${jitsi_hostname}.key /etc/ssl/jitsi-meet/cert.key

cat << EOF > /etc/haproxy/haproxy.cfg
frontend JitsiMeetSSL
    bind :443 ssl alpn h2,http/1.1 crt-list /etc/ssl/jitsi-meet
    mode http
    option http-keep-alive
    option forwardfor
    timeout client 30s
    option httplog
    reqadd X-Forwarded-Proto:\ https
    default_backend JistMeetSSL

backend JistMeetSSL
    mode http
    balance source
    stick-table type ip size 50k expire 30m  
    stick on src
    timeout connect 30s
    timeout server 30s
    http-reuse safe
    server JitsiMeetSSL 172.27.19.10:443 ssl verify none alpn h2,http/1.1
EOF

apt-get install haproxy
