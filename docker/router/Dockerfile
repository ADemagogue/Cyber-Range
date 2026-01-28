FROM alpine:3.19

# hadolint ignore=DL3018
RUN apk add --no-cache \
    bash \
    iproute2 \
    iptables

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
