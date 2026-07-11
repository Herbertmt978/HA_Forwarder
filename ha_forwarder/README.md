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

The App runs in an isolated bridge network, raising its Supervisor security
rating from 5 to 6. Its TCP listener remains unauthenticated and plaintext; it
does not provide client filtering, UDP forwarding, or protocol conversion.
Use it only on a trusted LAN.

Read the [full documentation](DOCS.md) before exposing the host port.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
