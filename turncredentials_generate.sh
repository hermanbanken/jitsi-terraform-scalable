echo "Set $SECRET (export SECRET=foobar) to run this!"
echo "Using these credentials you can test time-limited credentials protected turn servers"
echo "with https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/."

secret=$SECRET && \
time=$(date +%s) && \
expiry=8400 && \
username=$(( $time + $expiry )) &&\
echo username:$username && \
echo password : $(echo -n $username | openssl dgst -binary -sha1 -hmac $secret | openssl base64)
