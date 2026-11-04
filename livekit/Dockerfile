# Stock LiveKit, not openvidu/openvidu-server: that fork tests the public IP with a UDP hairpin,
# which cannot pass on Railway, and then advertises the private address instead of the proxy.
FROM livekit/livekit-server:v1.13.11
# socat bridges the TCP proxy's container port onto the ICE port; dig finds the proxy's IP.
RUN apk add --no-cache socat bind-tools
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
ENTRYPOINT ["/railway-entrypoint.sh"]
