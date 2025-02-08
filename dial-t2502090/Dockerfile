FROM ghcr.io/lwmacct/250209-cr-ubuntu:noble-t2502090

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250209-cr-pppoe
LABEL org.opencontainers.image.description="My container image"
LABEL org.opencontainers.image.licenses=MIT

ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; echo "apt"; \
    apt-get update && apt-get install -y --no-install-recommends pppoe* miniupnpd miniupnpc isc-dhcp-server isc-dhcp-client arping ipcalc mtr iperf3 -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

