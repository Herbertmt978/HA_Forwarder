# HA Forwarder

HA Forwarder is a lightweight Home Assistant App (formerly add-on) that
relays raw TCP traffic from the Home Assistant host to another TCP service.
It is useful when a device can only connect to the Home Assistant address
while the service that should receive its traffic runs elsewhere.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[![Open your Home Assistant instance and add this App repository][install-badge]][install-link]

## Requirements

- Home Assistant OS with Apps support.
- A destination TCP service reachable from the Home Assistant host.
- An unused TCP listen port on the Home Assistant host.

## Installation

Use the button above, or install the repository manually:

1. In Home Assistant, go to **Settings → Apps → App store**.
2. Open the three-dot menu and choose **Repositories**.
3. Add `https://github.com/Herbertmt978/HA_Forwarder`.
4. Install **HA Forwarder**.

The first installation builds a small container locally and can take a few
minutes on lower-powered hardware.

## Quick configuration

```yaml
target_host: "example.local"
target_port: 5279
max_connections: 64
connect_timeout: 15
```

`target_host` is required. HA Forwarder always listens on TCP 5279 inside its
container, and Home Assistant publishes that listener on host TCP 5279 by
default. To use a different host port, open **Settings → Apps → HA
Forwarder → Configuration** and change the host port beside `5279/tcp` in
the **Network** section. Save the configuration, start the App, then point the
sending device at the Home Assistant host and the selected host port.

See the [complete operating guide](ha_forwarder/DOCS.md) for option ranges,
verification, security details, limitations, and troubleshooting.

## Security

HA Forwarder no longer shares the host network namespace. Supervisor runs the
container in a network namespace separate from the host, connects it to a
Supervisor-managed internal bridge network, and publishes the configured TCP
mapping.
That metadata gives version 0.3.0 a calculated Supervisor security rating of 6,
compared with version 0.2.1's observed rating of 5. The published TCP listener
remains unauthenticated and plaintext and does not add encryption, source
filtering, or protocol validation. Keep it on a trusted LAN and do not expose
its host port directly to the internet. A custom AppArmor profile limits the
container's filesystem and process access.

Removing host networking changes loopback and other local-only destinations.
Before upgrading,
replace loopback or local-only `target_host` values, including `localhost`,
`localhost.`, `localhost.localdomain`, any `127.0.0.0/8` address, `0.0.0.0`,
and `::1` or `[::1]`, with a hostname or IP address reachable from the App
container. In versions before 0.3.0 those values referred to the Home Assistant
host or its local network stack; in version 0.3.0 they refer to the App
container itself. Non-loopback destinations keep their existing forwarding
behavior.

## Development

The repository includes runtime tests and pull-request validation:

```bash
bash tests/test_run.sh
docker build --build-arg BUILD_ARCH=amd64 \
  --build-arg BUILD_VERSION=dev \
  --tag ha-forwarder:dev \
  ha_forwarder
```

The runtime test requires `jq`. The container build requires Docker BuildKit.

## Support and license

Report reproducible problems through
[GitHub Issues](https://github.com/Herbertmt978/HA_Forwarder/issues) and include
the App version, Home Assistant version, architecture, redacted configuration,
and relevant App logs.

HA Forwarder is available under the [MIT License](LICENSE).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[install-badge]: https://my.home-assistant.io/badges/supervisor_store.svg
[install-link]: https://my.home-assistant.io/redirect/supervisor_store/?repository_url=https%3A%2F%2Fgithub.com%2FHerbertmt978%2FHA_Forwarder
