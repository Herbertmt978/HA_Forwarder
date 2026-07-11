# Spec Brief: Network Isolation and Rating 6

Status: approved by the user on 2026-07-11

## Outcome

Raise HA Forwarder's Home Assistant security rating from 5 to 6 by removing
host networking and exposing its fixed internal TCP listener through a
Supervisor-managed port mapping.

## Approved design

- Release the contract change as `0.3.0` and mark it breaking.
- Remove `host_network: true`.
- Map container `5279/tcp` to host TCP port 5279 by default.
- Fix the internal `socat` listener at TCP 5279.
- Remove `listen_port` from App options and translations.
- Let operators change the host-side port in Home Assistant's Network section.
- Remove the no-longer-needed AppArmor `net_bind_service` capability.
- Keep destination, connection limit, timeout, IPv6 target, injection, and loop
  protections unchanged.

## Compatibility boundary

The production route remains `192.168.50.29:5279` to
`192.168.50.89:5279`. Both existing clients must reconnect. Raw TCP data must
remain bidirectional and unchanged. A stale saved `listen_port` must not alter
the fixed internal listener and must be removed from persisted options during
the live migration.

The UI location of the host listen port changes from Options to Network. Users
who previously selected a non-default listen port must re-enter it in Network.

## Acceptance evidence

- Home Assistant reports rating 6.
- Docker network mode is not `host`.
- Host port 5279 publishes container `5279/tcp`.
- Both production clients and both destination sessions are established.
- Grott writes a post-cutover log entry with no fatal error.
- App logs and the kernel audit trail contain no relevant errors or AppArmor
  denials.
- CI lint, shell tests, AppArmor compilation, and container build pass.

## Security boundaries

No ingress, authentication API, Supervisor API, Docker API, full access,
privileged capability, host PID, or host UTS access will be added. A score of 7
will not be pursued by granting unrelated access.

## Rollback

Create a partial Home Assistant backup of v0.2.1 immediately before the update.
Keep the app stopped while applying its sanitized options and explicit network
mapping. If v0.3.0 cannot pass the live checks, restore only
`24118d52_ha_forwarder` from that backup.

## Non-goals

TLS termination, authentication, client allowlists, UDP, inbound IPv6,
protocol parsing, payload storage, and changes to the destination service are
not part of this release.

## Architecture signal

This is a durable install/runtime contract change. The baseline must be updated
after implementation. A separate ADR is unnecessary unless implementation
requires a second listener owner, compatibility adapter, or new permission.
