FROM openvidu/egress:3.9.0
USER root
COPY railway-entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
USER egress
ENTRYPOINT ["/railway-entrypoint.sh"]
