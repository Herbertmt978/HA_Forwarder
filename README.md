<div align="center">

# TCP Relay for Home Assistant

**Forward device TCP connections through Home Assistant to another host.**

[![Home Assistant App security rating: 6 out of 6][security-rating-badge]][security-rating-link]
[![Validate workflow status][validation-badge]][validation-link]
[![Latest release][release-badge]][release-link]
[![MIT license][license-badge]][license-link]
[![Supported architectures: amd64 and aarch64][architectures-badge]][architectures-link]
[![AppArmor custom profile][apparmor-badge]][apparmor-link]

[![Open your Home Assistant instance and add this App repository][install-badge]][install-link]

[Installation](#installation) · [Configuration](#configuration) · [Security](#security) · [Full App documentation](ha_forwarder/DOCS.md)

</div>

A device can sometimes reach the Home Assistant address while the TCP service
that needs its stream runs on another host. TCP Relay accepts that connection
through a Home Assistant host port and sends the same byte stream to one
configured destination.

## Installation

You need Home Assistant OS with Apps support, an unused TCP port on the Home
Assistant host, and a destination service reachable from the App container.

### Trust at a glance

| Area | What to expect |
|------|----------------|
| Network touch | TCP Relay accepts connections on the selected Home Assistant host port and opens one outgoing TCP connection to the configured destination for each accepted client. Its container listener is fixed at TCP 5279. |
| Platform access | It does not use the Home Assistant, Supervisor, or Docker API, and it does not use host networking. Supervisor runs it in a separate namespace on an internal bridge network. |
| Data handling | It relays bytes unchanged in both directions. It does not queue or replay payloads, inspect their contents, or send telemetry. |
| Connection protection | The listener is plaintext TCP with no authentication. Use it on a trusted LAN only, and never expose the port directly to the internet. |
| Stop or remove | Stop the App to close the listener and active relay sessions. Uninstall the App to remove the relay. |

Use the button above, or install the repository manually:

1. In Home Assistant, go to **Settings → Apps → App store**.
2. Open the three-dot menu and choose **Repositories**.
3. Add `https://github.com/Herbertmt978/HA_Forwarder`.
4. Install **TCP Relay**.

The first installation builds a small container locally and can take a few
minutes on lower-powered hardware.

## Traffic path

With the sample configuration below, traffic follows this path:

```text
device -> Home Assistant:selected host port -> TCP Relay -> target_host:target_port
device -> homeassistant.local:5279          -> TCP Relay -> example.local:5279
```

A successful start produces this log line:

```text
[INFO] Forwarding TCP 5279 to example.local:5279 (max 64 connections, 15s connect timeout)
```

## Configuration

The complete quick configuration has four options:

```yaml
target_host: "example.local"
target_port: 5279
max_connections: 64
connect_timeout: 15
```

| Option | Required | Default | Allowed value |
|--------|----------|---------|---------------|
| `target_host` | Yes | None | Destination DNS name or IP address; no scheme, port, whitespace, or commas. |
| `target_port` | No | `5279` | Destination TCP port, 1–65535. |
| `max_connections` | No | `64` | Concurrent forwarding sessions, 1–256. |
| `connect_timeout` | No | `15` | Seconds allowed to establish each destination connection, 1–300. |

TCP Relay always listens on TCP 5279 inside its container. Home Assistant maps
that listener to host TCP 5279 by default. To choose another host port, open
**Settings → Apps → TCP Relay → Configuration** and change the host port beside
`5279/tcp` in the **Network** section. Save the configuration, start the App,
then point the sending device at the Home Assistant address and selected host
port.

## How it works and its limits

- Supervisor runs the App in a separate network namespace connected to a
  Supervisor-managed internal bridge, then publishes the configured host port
  to the fixed container listener on TCP 5279.
- The listener accepts inbound IPv4 TCP connections. UDP and inbound IPv6 are
  not supported; IPv6 destinations are supported.
- All clients use one configured destination. Each accepted client creates one
  forwarding session and one new destination connection, up to
  `max_connections` concurrent sessions.
- `connect_timeout` limits destination connection setup only. It does not end
  an established idle connection.
- Bytes flow unchanged in both directions. They are not buffered for later
  delivery or replayed after failure.
- The original client's source address is not preserved; the destination sees
  the Home Assistant host as the connection source.
- Configuration is read at App startup. Restart after changing an option or
  Network port mapping.
- TCP Relay provides no TLS, authentication, client allowlist, source-based
  rate limiting, payload inspection, protocol validation, or protocol
  conversion.
- Do not point the destination back at the same Home Assistant host and
  published port. Startup rejects obvious localhost loops on TCP 5279, but it
  cannot reliably detect aliases or loops through a custom host port.

See the [full App documentation](ha_forwarder/DOCS.md) for operating details,
verification steps, troubleshooting, and all update guidance.

## Security

The [verified version 0.3.0 rollout][rollout-evidence-link] reports the maximum
rating of 6 on [Home Assistant's current 1-to-6 scale][security-rating-link];
version 0.2.1 was observed at rating 5. That rating reflects the App's
Supervisor isolation settings, including removal of host networking. It does
not add protection to the relayed TCP protocol or payload.

A custom [AppArmor profile][apparmor-link] restricts the container's filesystem
and process access. The published listener remains an unauthenticated,
plaintext network endpoint, so the trusted-LAN boundary in the installation
section still applies.

## Updating from versions before 0.3.0

Version 0.3.0 removed host networking and replaced the old `listen_port`
option with Home Assistant's `5279/tcp` Network mapping. Review these steps
before upgrading an older installation.

<details>
<summary>Migration steps for loopback destinations and custom ports</summary>

### Replace loopback and local-only destinations

Before version 0.3.0, `localhost`, `localhost.`, `localhost.localdomain`, any
`127.0.0.0/8` address, `0.0.0.0`, and IPv6 loopback written as `::1` or `[::1]`
referred to the Home Assistant host or its local network stack. From version
0.3.0, they refer to the App container and no longer reach a service bound only
to the Home Assistant host.

Replace those values with a hostname or IP address reachable from the App
container before upgrading. This loopback-specific migration does not apply to
direct routes to services on separate LAN hosts, but verify every route after
the upgrade.

### Preserve a custom host port

If the older App used a custom `listen_port`, record it and stop the App before
updating. After installing version 0.3.0 or later, stop the App again if it
started automatically, then set the host port beside `5279/tcp` in the
**Network** section to the recorded value. Remove any stale `listen_port` key,
save, and restart. The container side remains TCP 5279.

If the older App used the default port, confirm that the `5279/tcp` host mapping
is still 5279 after the update. In both cases, verify the forwarding log and
delivery to the destination service.

</details>

## Development

Run the documentation, configuration, and runtime checks, then build the
container:

```bash
bash tests/test_branding.sh
bash tests/test_config.sh
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

TCP Relay is available under the [MIT License](LICENSE).

[security-rating-badge]: https://img.shields.io/badge/App%20security-6%20%2F%206-brightgreen?logo=homeassistant&logoColor=white
[security-rating-link]: https://developers.home-assistant.io/docs/apps/security/
[validation-badge]: https://github.com/Herbertmt978/HA_Forwarder/actions/workflows/validate.yml/badge.svg?branch=main&event=push
[validation-link]: https://github.com/Herbertmt978/HA_Forwarder/actions/workflows/validate.yml?query=branch%3Amain
[release-badge]: https://img.shields.io/github/v/release/Herbertmt978/HA_Forwarder?display_name=tag&sort=semver&logo=github&label=release
[release-link]: https://github.com/Herbertmt978/HA_Forwarder/releases/latest
[license-badge]: https://img.shields.io/github/license/Herbertmt978/HA_Forwarder?logo=opensourceinitiative
[license-link]: LICENSE
[architectures-badge]: https://img.shields.io/badge/architectures-amd64%20%7C%20aarch64-blue?logo=linux&logoColor=white
[architectures-link]: ha_forwarder/config.yaml
[apparmor-badge]: https://img.shields.io/badge/AppArmor-custom%20profile-success?logo=ubuntu&logoColor=white
[apparmor-link]: ha_forwarder/apparmor.txt
[rollout-evidence-link]: docs/aegis/work/2026-07-11-network-isolation/90-evidence.md
[install-badge]: https://my.home-assistant.io/badges/supervisor_store.svg
[install-link]: https://my.home-assistant.io/redirect/supervisor_store/?repository_url=https%3A%2F%2Fgithub.com%2FHerbertmt978%2FHA_Forwarder
