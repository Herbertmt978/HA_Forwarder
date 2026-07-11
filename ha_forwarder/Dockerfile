ARG BUILD_FROM=ghcr.io/home-assistant/base:3.23-2026.06.1
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_VERSION

RUN apk add --no-cache socat

COPY --chmod=0755 run.sh /run.sh

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="${BUILD_ARCH}" \
    org.opencontainers.image.title="Home Assistant App: TCP Relay" \
    org.opencontainers.image.description="Forward device TCP connections through Home Assistant to another host." \
    org.opencontainers.image.source="https://github.com/Herbertmt978/HA_Forwarder" \
    org.opencontainers.image.licenses="MIT"

CMD [ "/run.sh" ]
