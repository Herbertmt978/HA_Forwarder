# Home Assistant App: HA Forwarder

_Forward raw TCP traffic from the Home Assistant host to another service._

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

HA Forwarder accepts concurrent TCP connections on a configurable host port
and relays each connection to one configured destination. Connection and
target setup limits keep a failed or overloaded destination from creating an
unbounded number of child processes.

This App uses host networking. It does not provide authentication, encryption,
client filtering, UDP forwarding, or protocol conversion. Use it only on a
trusted network.

Read the [full documentation](DOCS.md) before exposing the listen port.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
