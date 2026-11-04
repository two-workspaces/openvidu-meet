FROM openvidu/openvidu-server:3.9.0
# socat bridges the TCP proxy's container port onto the ICE port; dig finds the proxy's IP.
RUN apk add --no-cache socat bind-tools
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
ENTRYPOINT ["/railway-entrypoint.sh"]
