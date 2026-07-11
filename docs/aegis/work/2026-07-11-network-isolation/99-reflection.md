# Reflection

## Goal fit

The change reached the honest Supervisor security ceiling for this raw TCP
relay: live rating 6 without ingress, authentication APIs, or other unrelated
permissions. The existing Home Assistant host port, direct LAN target,
connection limits, timeout, boot behavior, watchdog, and auto-update behavior
continued working after rollout.

## Deeper cause

The original design made the process-level `listen_port` option responsible
for host port ownership, which in turn required the App to share the host
network namespace. Moving host-port ownership to Supervisor and fixing only the
container listener separated deployment configuration from runtime behavior.

## Evidence strength

The work used RED/GREEN tests, focused spec and quality reviews, full GitHub CI
on both the pull request and exact merge commit, an annotated release tag, a
verified pre-update backup, and live network/session/application evidence. The
rollout remained at zero restarts while Grott published both devices over
multiple consecutive cycles.

## Review value

Reviews caught unsafe custom-port instruction ordering, overstated network
isolation, stale evidence wording, the host-network-to-bridge loopback semantic
change, and incomplete YAML boolean normalization. Correcting those findings
made the migration safer and the security claim more precise.

## Architecture and retirement closure

Supervisor is now the single owner of the published host port. Runtime and
schema access to `listen_port`, host networking, and the unnecessary AppArmor
`net_bind_service` capability are retired. Remaining `listen_port` references
are intentionally limited to migration or history.

## Residual risk

The App still relays unauthenticated plaintext TCP and belongs only on a trusted
LAN. Custom host-port and loopback/local-only upgrades require manual operator
steps. The metadata regression guard is deliberately lightweight and code
review remains the backstop for unusual YAML indirection.

## Outcome

Complete. Version 0.3.0 is released, live at rating 6, and backed by retained
rollback backup `30cd2c41`.
