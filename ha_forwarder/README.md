# Home Assistant App: HA Forwarder

_Forward raw TCP traffic from the Home Assistant host to another service._

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
from the host, for a calculated version 0.3.0 security rating of 6 compared
with version 0.2.1's observed rating of 5. Only host networking is removed: the
published TCP listener remains unauthenticated and plaintext and does not
provide client filtering, UDP forwarding, or protocol conversion. Use it only
on a trusted LAN.

Read the [full documentation](DOCS.md) before exposing the host port.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
