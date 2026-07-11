# Home Assistant App: TCP Relay

_Forward device TCP connections through Home Assistant to another host._

[![Home Assistant App security rating: 6 out of 6][security-rating-badge]][security-rating-link]
[![AppArmor custom profile][apparmor-badge]][apparmor-link]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

TCP Relay accepts device connections on a port published by Home Assistant and
relays each connection to one configured TCP service:

```text
device -> Home Assistant:selected host port -> TCP Relay -> target_host:target_port
```

The container listener is fixed at TCP 5279. The host port defaults to 5279 and
can be changed in the App's **Network** section. Concurrent-session and
connection-timeout limits keep unavailable destinations from creating
unbounded child processes.

Supervisor runs the App in a separate network namespace on an internal bridge;
it does not use host networking. Version 0.3.0 receives the maximum rating of 6
on [Home Assistant's current 1-to-6 scale][security-rating-link], and a custom
AppArmor profile restricts container access. The published listener is still
plaintext and unauthenticated. Use it only on a trusted LAN, and never expose
the port directly to the internet.

## Limits

- TCP only: inbound IPv4 is supported; inbound IPv6 and UDP are not. IPv6
  destinations are supported.
- One configured destination, with unchanged bytes relayed in both directions.
- No TLS, authentication, client allowlist, source-based rate limiting, payload
  inspection, protocol validation, or protocol conversion.
- The original client source address is not preserved.

## Important update note

Version 0.3.0 removed host networking. Before updating from an earlier version,
replace loopback or local-only `target_host` values with an address reachable
from the App container. If you used a custom `listen_port`, preserve it with
the `5279/tcp` host mapping in the App's **Network** section and remove the stale
option.

Read the [full documentation](DOCS.md) for configuration ranges, migration
steps, security details, verification, and troubleshooting.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[security-rating-badge]: https://img.shields.io/badge/App%20security-6%20%2F%206-brightgreen?logo=homeassistant&logoColor=white
[security-rating-link]: https://developers.home-assistant.io/docs/apps/security/
[apparmor-badge]: https://img.shields.io/badge/AppArmor-custom%20profile-success?logo=ubuntu&logoColor=white
[apparmor-link]: https://github.com/Herbertmt978/HA_Forwarder/blob/main/ha_forwarder/apparmor.txt
