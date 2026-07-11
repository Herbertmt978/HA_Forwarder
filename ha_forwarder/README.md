# Home Assistant App: HA Forwarder

_Forward raw TCP traffic from the Home Assistant host to another service._

[![Home Assistant App security rating: 6 out of 6][security-rating-badge]][security-rating-link]
[![AppArmor custom profile][apparmor-badge]][apparmor-link]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

HA Forwarder accepts concurrent TCP connections on a host port published by
Home Assistant Supervisor and relays each connection to one configured
destination. The container listener is fixed at TCP 5279; the host port
defaults to 5279 and can be changed in the App's **Network** section.
Connection and target setup limits keep a failed or overloaded destination
from creating an unbounded number of child processes.

The App no longer shares the host network namespace. Supervisor runs it on a
Supervisor-managed internal bridge network within a network namespace separate
from the host. Version 0.3.0 receives the maximum rating of 6 on
[Home Assistant's current 1-to-6 scale][security-rating-link]; version 0.2.1
was observed at rating 5. The published TCP listener remains unauthenticated
and plaintext and does not provide client filtering, UDP forwarding, or
protocol conversion. Use it only on a trusted LAN.

Version 0.3.0 changes loopback and other local-only destinations. Before
upgrading, replace a loopback or local-only `target_host` value, including
`localhost`, `localhost.`,
`localhost.localdomain`, any `127.0.0.0/8` address, `0.0.0.0`, and `::1` or
`[::1]`, with a hostname or IP address reachable from the App container.
Earlier versions treated those values as destinations on the Home Assistant
host or its local network stack; version 0.3.0 treats them as destinations
inside the App container.
This loopback-specific migration does not apply to direct routes to services
on separate LAN hosts; verify every route after upgrading.

Read the [full documentation](DOCS.md) before exposing the host port.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[security-rating-badge]: https://img.shields.io/badge/App%20security-6%20%2F%206-brightgreen?logo=homeassistant&logoColor=white
[security-rating-link]: https://developers.home-assistant.io/docs/apps/security/
[apparmor-badge]: https://img.shields.io/badge/AppArmor-custom%20profile-success?logo=ubuntu&logoColor=white
[apparmor-link]: https://github.com/Herbertmt978/HA_Forwarder/blob/main/ha_forwarder/apparmor.txt
